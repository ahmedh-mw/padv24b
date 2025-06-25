% Copyright 2025 The MathWorks, Inc.

function generate_github_pipeline(workspace, projectToRepoPath, matlabInstallationLocation, runnerLabels, build_folder)
    arguments
        workspace = pwd;
        projectToRepoPath = "";
        matlabInstallationLocation = "matlab_bin_path";
        runnerLabels = "github_runner_labels";
        build_folder = "_build_"
    end
    cp = openProject(strjoin({workspace,projectToRepoPath} , filesep));
    op = padv.pipeline.GitHubOptions;
    op.PipelineArchitecture = "IndependentModelPipelines";
    op.GeneratorVersion = 2;
    op.MatlabInstallationLocation = matlabInstallationLocation;     % "C:/Program Files/MATLAB/R2024b/bin";
    op.RunnerLabels = runnerLabels;                                 % "padv_win_agents";
    op.GeneratedPipelineDirectory = build_folder;                   % "_build_";
    op.StopOnStageFailure = true;
    op.RunprocessCommandOptions.GenerateJUnitForProcess = true;
    op.ReportPath = "$PROJECTROOT$/PA_Results/Report/PadvReport";
    op.ProjectToRepoPath = projectToRepoPath;                       % ""
    op.UseMatlabPlugin = false;
    
    % Docker image settings
    % examples: "matlab", "matlab-batch", "xvfb-run -a matlab", "xvfb-run -a matlab-batch"
    % op.MatlabLaunchCmd = "xvfb-run -a matlab-batch";
    % op.MatlabStartupOptions = "";
    % op.AddBatchStartupOption = false;
    % padv.pipeline.generatePipeline(op, "CIPipeline");
end