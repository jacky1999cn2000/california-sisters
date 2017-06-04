global class ScheduleJob implements Schedulable {
  global void execute(SchedulableContext sc) {
    ScheduleJobUtilities.updateCustomerInfo();
    ScheduleJobUtilities.updateFISTATS();
    ScheduleJobUtilities.updateProductInfo();
  }
}
