public class DNBMonitoringSchedule implements Schedulable{
	public void execute(SchedulableContext sc){
        DNBMonitoringHandler.ExecuteSchedule();
    }
}