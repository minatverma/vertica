from datetime import datetime, timedelta
from random import randint

__author__ = 'dbadmin'

def generateEventEntry(start_stamp, interval, unique_events_num=1):

    eventsSet = set()   # for uniqueness

    for event in xrange(unique_events_num):
        rand_day = randint(0,interval)
        rand_hour = randint(0,23)
        rand_minutes = randint(0,59)
        # to avoid round seconds such as 10,20,30,...
        rand_seconds = randint(1,9) + randint(1,5)*10
        rand_stamp =  datetime.strptime(start_stamp, "%Y%m%d%H%M%S")
        rand_stamp += timedelta(days=rand_day,
            hours=rand_hour,minutes=rand_minutes,seconds=rand_seconds)
        eventsSet.add(rand_stamp.strftime('%Y%m%d%H%M%S'))

    return eventsSet


def main():
    for i in generateEventEntry('20000101000000', 3, 5):
        print i

if __name__ == '__main__':
    main()
