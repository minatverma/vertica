import subprocess
from attr_dict import AttributeDictionary


__version__ = '0.0.1'
__author__ = 'daniel@twingo.co.il'
__all__ = ['PID', 'NAME', 'IS_STARTED', 'IS_DONE', 'EXIT_STATUS', 'STATISTICS', 'run', 'collectStatistics']


class ShellJob(object):
    """ DOCS """

    EXIT_SUCCESS = 0

    @property
    def PID(self):
        """ DOCS """
        return self._process.pid

    @property
    def NAME(self):
        """ DOCS """
        return self.label

    @property
    def IS_STARTED(self):
        """ DOCS """
        return hasattr(self, '_process')

    @property
    def IS_DONE(self):
        """ DOCS """
        return self.IS_STARTED and self._process.poll() is not None

    @property
    def EXIT_STATUS(self):
        """ DOCS """
        return self._process.returncode

    @property
    def STATISTICS(self):
        """ DOCS """
        return self._stats_dict

    @staticmethod
    def _getStatisticsFormatDictionary():
        """ DOCS """
        stats_dict = AttributeDictionary()
        stats_dict.EXEC_TIME    = '%e'     # Elapsed real time (in seconds).
        stats_dict.KERNEL_MODE  = '%S'     # CPU-seconds in kernel mode.
        stats_dict.USER_MODE    = '%U'     # CPU-seconds in user mode.
        stats_dict.CPU_USAGE    = '%P'     # CPU % that this job got
        stats_dict.MEM_USAGE    = '%K'     # AVG(data+stack+text) memory use Kb
        stats_dict.IO_WAITS     = '%w'     # Number of waits due IO
        stats_dict.IO           = '%I|%O'  # Number of system IO calls
        stats_dict.EXIT_STATUS  = '%x'     # Exit status of the shell command
        stats_dict.IRQ          = '%k'     # Number delivered signals
        stats_dict.CMD          = '%C'     # Name and command-line arguments
        return stats_dict

    def __init__(self, shell_cmd, label=None, collect_stats=False):
        """ DOCS """
        super(ShellJob, self).__init__()
        self.shell_command = shell_cmd
        self.label = label
        self.collect_stats = collect_stats

    def run(self):
        """ DOCS """
        cmd = self.shell_command
        if self.collect_stats:
            form_str = repr(ShellJob._getStatisticsFormatDictionary())
            form_str = form_str[form_str.find('(') + 1 : form_str.rfind(')')]
            form_str = ''.join(["'",form_str.replace("'", '"'),"'"])
            cmd = ' '.join(["/usr/bin/time", '-f', form_str, "--", cmd])
        run = subprocess.Popen
        PIPE = subprocess.PIPE
        self._process = run(cmd.strip(), stdout=PIPE, stderr=PIPE, shell=True)

    def collectStatistics(self, force=False):
        """ DOCS """
        stats_dict = ShellJob._getStatisticsFormatDictionary()
        if force or self.IS_DONE:
            out, stats  = self._process.communicate()
            if self.EXIT_STATUS == ShellJob.EXIT_SUCCESS:
                result_dict = eval(stats)
                for key in stats_dict:
                    stats_dict[key] = result_dict[key]
                stats_dict.CMD_OUT = out
            else:
                pass                # TODO: logger - cmd failed
        else:
            pass                    # TODO: runtime statistics
        self._stats_dict = stats_dict


    def printStatistics(self):
        """ DOCS """
        if self._stats_dict:
            for key in self._stats_dict:
                print key, self._stats_dict[key]



if __name__ == '__main__':

    c1 = 'sleep 4'
    c2 = r'/opt/vertica/bin/vsql -c  "copy t from ' + r"'/tmp/data.dat'" + r' direct"'

    job = ShellJob(shell_cmd=c2, collect_stats=True)
    job.run()
    job.collectStatistics(force=True)

    print job.IS_STARTED, job.IS_DONE
    job.printStatistics()

