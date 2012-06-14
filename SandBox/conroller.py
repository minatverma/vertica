import argparse

__author__ = 'dbadmin'

DESCRIPTION = """
Generates ITEM_STATE_TABLE and EVENT_ITEM_TABLE
for testing purposes.
"""
PROG_NAME = 'TABLE GENERATOR FOR AMOS'

def usage():
    pass

def main():
    parser = argparse.ArgumentParser(prog=PROG_NAME, description=DESCRIPTION)
    parser.add_argument('--version', action='version', version='%(prog)s 0.0.1')
    parser.add_argument('-o','--output', default='/tmp/test_table.txt', help='bla bla bla')
#    parser.add_argument('--start_date', metavar='YYYYMMDDHHMISS', type=int, help='initial point for dates creation')
    args = parser.parse_args()
    print args
#    try:
#        opts, args = getopt.getopt(sys.argv[1:], "ho:v", ["help", "output="])
#    except getopt.GetoptError, err:
#        print str(err)
#        usage()
#        sys.exit(2)
#    output = None
#    verbose = False
#    for o, a in opts:
#        if o == "-v":
#            verbose = True
#        elif o in ("-h", "--help"):
#            usage()
#            sys.exit()
#        elif o in ("-o", "--output"):
#            output = a
#        else:
#            assert False, "unhandled option"

if __name__ == "__main__":
    main()
