    
%-----------------------------------------------------------------------
%
%    Maze-Solvig task
%    Maze maps will be loaded from the directory "world_maps"
%
%    If you would like to change worlds or to add new worlds, you will need
%    to edit files in the "world_maps" directory. 
%
%    For example, the world 1tunnel.txt looks like this:
%
%    3
%    6
%    000
%    030
%    032
%    030
%    030
%    003
%
%    The first two rows are world width and height;
%    The map is an array, in which each element can be empty (0), wall (3),
%    or exit (2). We assume there is always only one exit in each maze.
%
%    practice trials are not scored
%
%    pressing ESCAPE terminates the experiment; necessary to debug
%    or if something goes wrong during the session (e.g. the eyetracker
%    gave up or the patient has a sizeure)
%
%-----------------------------------------------------------------------

function [escaped_experiment, step_count, fileID] = ...
    solving_main_eyetracking(subject, ... % subject ID for this session
    window,                           ... % needed for Psychtoolbox
    mon,                              ... % screen dimensions
    dummy_mode,                       ... % run the task without ET and recording responses?
    draw_dots,                        ... % draw where the subject is curreltly looking
    el,                               ... % eyetracker 
    repeat_task_times )                   % how many times to repeat the task?

    %-----------------------------------------------------------------------
    % setup the experiment
    %-----------------------------------------------------------------------
         
    step_count = zeros(repeat_task_times, 1); 
    
    fixationlog_here = 'solving_log_dir/';               % logging

    for iBlock = 1: repeat_task_times
        test_maps_block{iBlock} = loadAllMaps(strcat(pwd, ['/block' num2str(iBlock) '/']));  % maze maps
        number_of_test_trials(iBlock) = size(test_maps_block{iBlock} ,1);
    end 
  
    demo_maps = loadAllMaps(strcat(pwd, '/practice_world_maps/'));               % practice maze maps
    number_of_practice_trials = size(demo_maps,1);           
    
    total_trials = number_of_test_trials(1);
           
    %-----------------------------------------------------------------------
    %
    % test_maps and demo_maps are arrays of filenames
    %
    %-----------------------------------------------------------------------
      
    
    %-----------------------------------------------------------------------
    %
    %  experimenter demo uses the pre-cofignred goal
    %
    %  patient practice ignores the baked in location of the goal, 
    %  and places the goal at a random location, this is to show that the
    %  goal really can be anywhere
    %
    %-----------------------------------------------------------------------
    
    practiceTrialPermutation = 1:1:number_of_practice_trials; % the first five trials are practice trials, which are not scored
    
    %-----------------------------------------------------------------------
    %
    % create the agent image
    %
    %-----------------------------------------------------------------------
    
    if ispc==0
        img = imread(strcat(pwd, '/tex/agent1.png')); % the agent's face
    else
        img = imread(strcat(pwd, '\tex\agent1.png'));
    end
    imageAgent = Screen('MakeTexture', window, img);
    

    %-----------------------------------------------------------------------
    %
    % instructions screen
    %
    %-----------------------------------------------------------------------
    
    fprintf('Showing instructions\n');
    flipTime = showInstructions(window);
    
    KbWait;
    [ keyIsDown, t, keyCode ] = KbCheck;   % wait for any key to be pressed
    KbReleaseWait;
    
    escapeKey = KbName('ESCAPE');
    if keyCode(escapeKey)
      fprintf('Experiment skipped.\n');
    else
       
      fprintf('Starting experiment...\n');
      
      fileID = fopen([fixationlog_here subject '_solving_log.txt'],'w');
      fprintf(fileID,  'timestamp\tsubject\trt\teyex\teyey\tdatatype\ttimefrom\ttimeto\tpupil');
      fprintf(fileID,  '\teyecellx\teyecelly\tworld\tpath\tvisible\ttrialtype');
      fprintf(fileID,  '\tkeyPressed\tkeyAction\tvalidAction\tblackremains\tnumsquaresopen');
      fprintf(fileID,  '\tsquaretype\tnumexits\n');  % The log file format  
       
%       fprintf('Starting demo...\n');
%       
%       [escaped_experiment, step_counter] = trialsLoop( imageAgent, ...
%             practiceTrialPermutation, ... % the order in which the worlds will be shown
%             demo_maps, ...                % the array of world maps loaded from file
%             0, ...                        % 0 -- demo, 1 -- practice, 2 -- experiment
%             fileID,...                    % the file where all data will be saved
%             window,...                    % needed by Psychtoolbox
%             mon,...                       % monitor config
%             subject,...                   % subject ID for this session
%             0,...                         % the index of the first trial in this block
%             number_of_practice_trials,... % number of trials in total in this block
%             dummy_mode,               ... % run the task without ET and recording responses?
%             draw_dots,                ... % draw where the subject is curreltly looking
%             el );                          % eyetracker 
% 
        
      %-----------------------------------------------------------------------
      %
      %    Intro to practice 
      % 
      %-----------------------------------------------------------------------
      
%       if escaped_experiment
%           fprintf('Demo skipped...\n');
%           escaped_experiment = 0;
%       end
      escaped_experiment = 0;
%       escaped_experiment = showIntroToPractice(window);
%       
%       if escaped_experiment
%           fprintf('Practice skipped...\n');
%       end
%                  
%       if ~escaped_experiment
%             
%             repeat_practice = 0;
%             
%             while repeat_practice == 2 && ~escaped_experiment
%              
%                 fprintf('Starting practice...\n');
%                 
%                 [escaped_experiment, step_counter] = trialsLoop( imageAgent, ...
%                     practiceTrialPermutation, ... % the order in which the worlds will be shown
%                     demo_maps, ...% the array of world maps loaded from file
%                     1, ... % 0 -- demo, 1 -- practice, 2 -- experiment
%                     fileID, window, mon, subject, 0, number_of_practice_trials, dummy_mode, draw_dots, el );
%                 
%                  %-----------------------------------------------------------------------
%                  %
%                  %    Ask if the subject wants to continue 
%                  %
%                  %-----------------------------------------------------------------------
%                  
%                  repeat_practice = askIfMorePractice(window, repeat_task_times, total_trials);
%                  
%                  if repeat_practice == 1
%                      escaped_experiment=1;
%                  end
%                  
%             end
%       else
%           escaped_experiment = 0;
%       end
      done = 0;
      
      %-----------------------------------------------------------------------
      %
      %    Here is the main experiment loop 
      %
      %-----------------------------------------------------------------------         

      while ~escaped_experiment && ~done
         
            %-----------------------------------------------------------------------
            %
            %    Show trials  
            %
            %-----------------------------------------------------------------------
      
            testTrialsPermutation = randperm(number_of_test_trials(1));
            
            [escaped_experiment, step_counter] = trialsLoop( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_block{1}, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, 0, total_trials, dummy_mode, draw_dots, el );

            step_count(1) = step_count(1) + step_counter;
            
            if escaped_experiment
                break;
            end
            
            repeats = 1;
            while repeats < repeat_task_times

                    repeats = repeats + 1;
                    
                    escaped_experiment = showSplash(window);

                    if  escaped_experiment
                        fprintf('Second half skipped...\n');
                        break;
                    end

                    total_trials = number_of_test_trials(repeats);
                    
                    testTrialsPermutation  = randperm(number_of_test_trials(repeats)); 

                    [escaped_experiment, step_counter] = trialsLoop( imageAgent, ... 
                        testTrialsPermutation, ... % the order in which the worlds will be shown
                        test_maps_block{repeats}, ...% the array of world maps loaded from file
                        2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                        fileID, window, mon, subject, 0, total_trials, dummy_mode, draw_dots, el );

                    step_count(repeats) = step_count(repeats) + step_counter;
                   
                    if escaped_experiment
                        break;
                    end                   
            end

            done = 1;
        end

    end
    
    
end