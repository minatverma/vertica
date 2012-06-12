#import sys

__author__ = 'dbadmin'


class export_parser(object):

    def __init__(self):

        self.tbl_name                 = None
        self.prj_name                 = None

        self.tbl_is_create            = False
        self.prj_is_create            = False
        self.prj_is_columns_order     = False
        self.prj_is_select            = False
        self.prj_is_order             = False

        self.tbl_columns              = None
        self.prj_columns              = None
        self.prj_select_columns       = None
        self.prj_order_columns        = None


    def parse_column(self, line, columns_list, start_token, end_token):
        if line.endswith(end_token):
            return  False
        if line != start_token:
            columns_list.append(line.split(',')[0])
        return True

    def init_section(self, line):
        if line.startswith('CREATE'):
            name = line.split(' ')[-1]
            if 'TABLE' in line:
                self.tbl_name = name
                self.tbl_is_create = True
                self.tbl_columns = list()
            elif 'PROJECTION' in line:
                self.prj_name = name
                self.prj_is_create = True
                self.prj_is_columns_order = True
                self.prj_columns = list()
            return True
        return False

    def init_sub_section(self, line):
        if line.startswith('SELECT'):
            self.prj_is_select = True
            self.prj_select_columns = list()
            line = line.replace('SELECT','').strip()
        elif line.startswith('ORDER BY'):
            self.prj_is_order = True
            self.prj_order_columns = list()
            line = line.replace('ORDER BY','').strip()
        return line

    def parse_section(self, line):
        if self.tbl_is_create:
            self.tbl_is_create = self.parse_column(line, self.tbl_columns, '(', ';')
        elif self.prj_is_create:
            line = self.init_sub_section(line)
            self.parse_projection(line)

    def parse_projection(self, line):
        if self.prj_is_columns_order:
            self.prj_is_columns_order = self.parse_column(line, self.prj_columns, '(', ')')
        elif self.prj_is_select:
            an_boolean = self.parse_column(line, self.prj_select_columns, 'SELECT', self.tbl_name)
            self.prj_is_select = an_boolean
            self.prj_is_order = not an_boolean
        elif self.prj_is_order:
            an_boolean = self.parse_column(line, self.prj_order_columns, '', ';')
            self.prj_is_order = an_boolean
            self.prj_is_create = an_boolean

    def parse_line(self, line):
        if not self.init_section(line):
            self.parse_section(line)

if __name__ == '__main__':
    ep = export_parser()
    f = open('/tmp/def.sql','r')
    for l in f:
        l = l.strip()
        l = l.strip('\n')
        ep.parse_line(l)
    f.close()
    print 'tbl_name :', '\t' + ep.tbl_name
    print 'prj_name :', '\t' + ep.prj_name
    print ep.tbl_columns
    print ep.prj_columns
    print ep.prj_select_columns
    print ep.prj_order_columns