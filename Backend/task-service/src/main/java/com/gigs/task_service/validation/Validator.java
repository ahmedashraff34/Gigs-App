package com.gigs.task_service.validation;


import com.gigs.task_service.dto.request.TaskRequest;



import jakarta.validation.ValidationException;

public interface Validator<T> {

    void validate(T target) throws ValidationException;
}
