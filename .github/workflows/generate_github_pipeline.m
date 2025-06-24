% Copyright 2025 The MathWorks, Inc.

op = padv.pipeline.GitHubOptions;
op.PipelineArchitecture = "IndependentModelPipelines";
op.GeneratorVersion = 2;
op.MatlabInstallationLocation = matlabInstallationLocation;
op.RunnerLabels = runnerLabels;
op.GeneratedPipelineDirectory = "_build_";
op.StopOnStageFailure = true;
op.RunprocessCommandOptions.GenerateJUnitForProcess = true;
op.ReportPath = "$PROJECTROOT$/PA_Results/Report/PadvReport";
op.ProjectToRepoPath = projectToRepoPath;

% Docker image settings
op.UseMatlabPlugin = false;
% examples: "matlab", "matlab-batch", "xvfb-run -a matlab", "xvfb-run -a matlab-batch"
op.MatlabLaunchCmd = "xvfb-run -a matlab-batch";
op.MatlabStartupOptions = "";
op.AddBatchStartupOption = false;
padv.pipeline.generatePipeline(op, "CIPipeline");

