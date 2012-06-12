import random
import string
import datetime

__author__ = 'dbadmin'

HOURS_IN_DAY    =  1440     # 24 * 60

def generateItemName():
    item =  ''.join(random.choice(string.ascii_uppercase) for x in range(3))
    item += '-'
    item += ''.join(random.choice(string.digits) for x in range(3))
    return item

def generateItemState():
    return '%(number).4f' % {"number": random.uniform(2,64)}

def getItemTimeStamp(start_time, delta_time):
    d_time = datetime.timedelta(minutes=delta_time)
    return (start_time + d_time).isoformat(' ')

def generateItem(start_time, interval, delta, delimiter):
    rows = list()
    interval *= HOURS_IN_DAY
    name = generateItemName()
    for d in xrange(0, interval, delta):
        row = [name, generateItemState(), getItemTimeStamp(start_time, d)]
        rows.append(delimiter.join(row))
    return rows

def main():
    start_time      = datetime.datetime(2000,01,01,0,0,0)
    delta           = 150     # 150 minutes OR 2.5 hour
    delimiter       = '|'
    interval        =  2      # days
    for row in generateItem(start_time, interval, delta, delimiter):
        print row

if __name__ == "__main__":
    main()