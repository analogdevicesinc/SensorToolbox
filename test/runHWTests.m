function runHWTests(board)

    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.TestReportPlugin;
    import matlab.unittest.plugins.XMLPlugin
    import matlab.unittest.plugins.DiagnosticsValidationPlugin
    import matlab.unittest.parameters.Parameter
    import matlab.unittest.plugins.ToUniqueFile;
    import matlab.unittest.plugins.TAPPlugin;
    import matlab.unittest.constraints.ContainsSubstring;
    import matlab.unittest.selectors.HasName;
    import matlab.unittest.selectors.HasProcedureName;

    switch(board)
        case "adis16460bmlz"
            at = 'ADIS16460';
        case "adis16480bmlz"
            at = 'ADIS16480';
        case "cn0532"
            at = 'CN0532';
        otherwise
            error('%s unsupported for HW test harness', board)
    end
    ats = {'ADIS16460Tests','ADIS16480Tests','CN0532Tests','CN0540Tests'};

    if nargin == 0
        suite = testsuite(ats);
    else
        suite = testsuite(ats);
        suite = selectIf(suite,HasProcedureName(ContainsSubstring(at,'IgnoringCase',true)));
    end
    try
        runner = matlab.unittest.TestRunner.withTextOutput('OutputDetail',1);
        runner.addPlugin(DiagnosticsValidationPlugin)
        xmlFile = board+"_HWTestResults.xml";
        plugin = XMLPlugin.producingJUnitFormat(xmlFile);
        
        runner.addPlugin(plugin);
        results = runner.run(suite);
        
        t = table(results);
        disp(t);
        disp(repmat('#',1,80));
        for test = results
            if test.Failed
                disp(test.Name);
            end
        end
    catch e
        disp(getReport(e,'extended'));
        bdclose('all');
        exit(1);
    end
    save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH_MM_SS'),'.mat'],'t');
%     bdclose('all');
%     exit(any([results.Failed]));
end
