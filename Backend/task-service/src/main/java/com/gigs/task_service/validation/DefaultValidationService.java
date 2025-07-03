package com.gigs.task_service.validation;

import com.gigs.task_service.dto.request.TaskRequest;
import jakarta.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;


/**
 * Facade service that runs common validators and then dispatches to the
 * specific Validator based on the request's concrete class.
 */
@Service
public class DefaultValidationService implements ValidationService {

    private final List<Validator<TaskRequest>> commonValidators;
    private final List<Validator<UpdateContext>> updateValidators;
    private final Map<Class<? extends TaskRequest>, Validator<? extends TaskRequest>> validators;

    /**
     * @param commonValidators beans implementing Validator<TaskRequest> (shared rules)
     * @param updateValidators
     * @param allValidators    beans implementing Validator<T> for each TaskRequest subtype
     */
    @Autowired
    public DefaultValidationService(
            List<Validator<TaskRequest>> commonValidators,
            List<Validator<UpdateContext>> updateValidators, List<Validator<? extends TaskRequest>> allValidators
    ) {
        this.commonValidators = commonValidators;
        this.updateValidators = updateValidators;
        this.validators = allValidators.stream()
                .filter(v -> !commonValidators.contains(v))
                .collect(Collectors.toMap(
                        v -> {
                            // reflectively find the T in Validator<T>
                            ParameterizedType iface = (ParameterizedType) Arrays.stream(v.getClass().getGenericInterfaces())
                                    .filter(t -> t instanceof ParameterizedType
                                            && ((ParameterizedType) t).getRawType() == Validator.class)
                                    .map(t -> (ParameterizedType) t)
                                    .findFirst()
                                    .orElseThrow(() -> new IllegalStateException(
                                            "Missing generic interface on validator " + v.getClass().getSimpleName()));
                            Type arg = iface.getActualTypeArguments()[0];
                            @SuppressWarnings("unchecked")
                            Class<? extends TaskRequest> cls = (Class<? extends TaskRequest>) arg;
                            return cls;
                        },
                        Function.identity()
                ));
    }

    @SuppressWarnings("unchecked")
    private <T extends TaskRequest> Validator<T> lookup(TaskRequest req) {
        Validator<?> validator = validators.get(req.getClass());
        if (validator == null) {
            throw new ValidationException("No validator registered for request class "
                    + req.getClass().getSimpleName());
        }
        return (Validator<T>) validator;
    }

    @Override
    public void validateCreate(TaskRequest req) {
        commonValidators.forEach(v -> v.validate(req));
        lookup(req).validate(req);
    }

    @Override
    public void validateUpdate(Long taskId, TaskRequest req) {
        UpdateContext ctx = new UpdateContext(taskId, req);
        updateValidators.forEach(v -> v.validate(ctx));
        // then common request checks
        commonValidators.forEach(v -> v.validate(req));
        // then subtype-specific checks
        lookup(req).validate(req);
    }

    @Override
    public void validateDelete(Long taskId, TaskRequest req) {
        UpdateContext ctx = new UpdateContext(taskId, req);
        updateValidators.forEach(v -> v.validate(ctx));
    }
}