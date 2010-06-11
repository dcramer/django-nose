

class ResultPlugin(object):
    """
    Captures the TestResult object for later inspection.

    nose doesn't return the full test result object from any of its runner
    methods.  Pass an instance of this plugin to the TestProgram and use
    ``result`` after running the tests to get the TestResult object.
    """

    name = "result"
    enabled = True

    def finalize(self, result):
        self.result = result

class DjangoPlugin(object):
    name = "django"
    enabled = True

    def __init__(self, runner):
        self.runner = runner

    def prepareTestResult(self, test):
        self.old_names = self.runner.setup_databases()

    def finalize(self, result):
        self.runner.teardown_databases(self.old_names)
