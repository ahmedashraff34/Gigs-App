import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/offer_model.dart';
import '../models/task_model.dart';
import '../services/offer_service.dart';
import '../services/task_service.dart';
import '../services/event_application_service.dart';
import '../models/event_application_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

import '../widgets/my_box.dart';

class RunnerOffersScreen extends StatefulWidget {
  const RunnerOffersScreen({Key? key}) : super(key: key);

  @override
  State<RunnerOffersScreen> createState() => _RunnerOffersScreenState();
}

class _RunnerOffersScreenState extends State<RunnerOffersScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<OfferResponse>? offers;
  Map<int, String> taskTitles = {};
  bool isLoading = true;

  List<TaskResponse>? eventApplications;
  bool isLoadingApplications = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    fetchOffers();
    fetchEventApplications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchOffers();
      fetchEventApplications();
    }
  }

  Future<void> fetchOffers() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final runnerId = prefs.getString('userId');
    if (runnerId == null) {
      setState(() {
        offers = [];
        isLoading = false;
      });
      return;
    }
    final fetchedOffers =
        await OfferService().getOffersByRunner(int.parse(runnerId));
    final Map<int, String> titles = {};
    for (final offer in fetchedOffers) {
      final task = await TaskService().fetchRegularTaskById(offer.taskId);
      if (task != null) {
        titles[offer.taskId] = task.title;
      } else {
        titles[offer.taskId] = 'Unknown Task';
      }
    }
    setState(() {
      offers = fetchedOffers;
      taskTitles = titles;
      isLoading = false;
    });
  }

  Future<void> fetchEventApplications() async {
    setState(() => isLoadingApplications = true);
    final prefs = await SharedPreferences.getInstance();
    final runnerId = prefs.getString('userId');
    if (runnerId == null) {
      setState(() {
        eventApplications = [];
        isLoadingApplications = false;
      });
      return;
    }
    final fetchedApplications =
        await EventApplicationService().getTasksForRunner(int.parse(runnerId));
    setState(() {
      eventApplications = fetchedApplications;
      isLoadingApplications = false;
    });
  }

  Future<void> cancelOffer(int offerId) async {
    final success = await OfferService().cancelOffer(offerId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer cancelled successfully.')),
      );
      fetchOffers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel offer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers & Applications'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/runner-home',
              (route) => false,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Offers'),
              Tab(text: 'Event Applications'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        body: TabBarView(
          children: [
            // Tab 1: Offers
            RefreshIndicator(
              onRefresh: fetchOffers,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (offers == null || offers!.isEmpty)
                      ? const Center(child: Text('No offers found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppTheme.paddingLarge),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppTheme.paddingMedium),
                          itemCount: offers!.length,
                          itemBuilder: (context, i) {
                            final offer = offers![i];
                            final title = taskTitles[offer.taskId] ?? '...';
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.paddingLarge),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: AppTheme.headerTextStyle
                                            .copyWith(fontSize: 20)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money,
                                            color: AppTheme.primaryColor,
                                            size: 20),
                                        const SizedBox(width: 6),
                                        Text('Amount: ${offer.amount} EGP',
                                            style: AppTheme.textStyle1
                                                .copyWith(fontSize: 16)),
                                      ],
                                    ),
                                    if (offer.comment.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.comment,
                                              color: AppTheme.textColor1,
                                              size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                              child: Text(
                                                  'Comment: ${offer.comment}',
                                                  style: AppTheme.textStyle2)),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: AppTheme.textColor1,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                            'Status: ${offer.status.toString().split('.').last}',
                                            style: AppTheme.textStyle2),
                                        const Spacer(),
                                        if (offer.status == OfferStatus.PENDING)
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              minimumSize: Size(0, 0),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              backgroundColor: AppTheme
                                                  .urgentColor
                                                  .withOpacity(0.1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                cancelOffer(offer.offerId),
                                            icon: const Icon(Icons.close,
                                                color: AppTheme.urgentColor,
                                                size: 18),
                                            label: const Text('Cancel',
                                                style: TextStyle(
                                                    color: AppTheme.urgentColor,
                                                    fontSize: 13)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Tab 2: Event Applications
            RefreshIndicator(
              onRefresh: fetchEventApplications,
              child: isLoadingApplications
                  ? const Center(child: CircularProgressIndicator())
                  : (eventApplications == null || eventApplications!.isEmpty)
                      ? const Center(
                          child: Text('No event applications found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppTheme.paddingLarge),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppTheme.paddingMedium),
                          itemCount: eventApplications!.length,
                          itemBuilder: (context, i) {
                            final task = eventApplications![i];
                            return MyBox(
                              boxPadding: AppTheme.paddingLarge,
                              margin: const EdgeInsets.only(bottom: 16),
                              boxChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: AppTheme.headerTextStyle
                                        .copyWith(fontSize: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.event,
                                          color: AppTheme.primaryColor,
                                          size: 20),
                                      const SizedBox(width: 6),
                                      Text('Event Task',
                                          style: AppTheme.textStyle1
                                              .copyWith(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    task.description,
                                    style: AppTheme.textStyle2,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: AppTheme.primaryColor,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text('Location: ${task.location ?? '-'}',
                                          style: AppTheme.textStyle2),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money,
                                          color: AppTheme.primaryColor,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                          'Fixed Pay: ${task.fixedPay?.toStringAsFixed(0) ?? '-'} EGP',
                                          style: AppTheme.textStyle2),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.people,
                                          color: AppTheme.primaryColor,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                          'Required People: ${task.requiredPeople ?? '-'}',
                                          style: AppTheme.textStyle2),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: AppTheme.primaryColor,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text('Start: ${task.startDate ?? '-'}',
                                          style: AppTheme.textStyle2),
                                      const SizedBox(width: 12),
                                      Text('End: ${task.endDate ?? '-'}',
                                          style: AppTheme.textStyle2),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.timelapse,
                                          color: AppTheme.primaryColor,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text('Days: ${task.numberOfDays ?? '-'}',
                                          style: AppTheme.textStyle2),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: AppTheme.textColor1, size: 18),
                                      const SizedBox(width: 6),
                                      Text('Status: ${task.status}',
                                          style: AppTheme.textStyle2),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Poster username and profile picture
                                  FutureBuilder<UserModel?>(
                                    future: UserService().getUserById(
                                        task.taskPoster.toString()),
                                    builder: (context, snapshot) {
                                      final user = snapshot.data;
                                      final hasProfilePic =
                                          user?.profileUrl != null &&
                                              user!.profileUrl!.isNotEmpty;
                                      return Row(
                                        children: [
                                          if (hasProfilePic)
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundImage: NetworkImage(
                                                  user!.profileUrl!),
                                            )
                                          else
                                            const CircleAvatar(
                                              radius: 14,
                                              child:
                                                  Icon(Icons.person, size: 18),
                                            ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Posted by: ${user?.username ?? 'Poster'}',
                                            style: AppTheme.textStyle2,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
