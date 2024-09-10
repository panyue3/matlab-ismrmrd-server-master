% /*
%  * Argus Flow Data Parser
%  *
%  * Author: Travis Sharkey-Toppen
%  * Date Created: 06.10.2008
%  * Version: 2.0.1
%  * 
%  * Purpose: Provide quick parsing of Argus Flow Data file for MATLAB.
%  *
%  *  [b,n,m,v,venc,argus] = parseArgusFlow(<filename>)
%  *  @param b - boolean for success of function
%  *  @param n - number of images processed per region
%  *  @param m - number of regions processed
%  *  @param v - vertices as cells
%  *    v{i}{j}{k} where 1<=i<=m, 1<=j<=n
%  *      v{i} : Regions
%  *      v{i}{j} : Specific Image's Region
%  *      v{i}{j}{1} : X Coordinates of Specific Image's Region
%  *      v{i}{j}{2} : Y Coordinates of Specific Image's Region
%  *
%  * Compilation:
%  *   No Compilation Required
%  *
%  * Updates:
%  *
%  * Testing:
%  *
%  * To-Do:
%  * 
%  * Notes: Complete rewrite from C Mex-File Version for better
%  *   interoperability
%  */

function [b,venc,n,m,t,v,argus] = processArgusFile(file)
  b = false;
  n = false;
  v = false;
  
  if nargin <= 0 || exist(file,'file') ~= 2
    [file,path] = uigetfile('*.txt');
    file = [path file];
  end
  % /* Open File */
  fp = fopen(file, 'r');
  if fp < 0
    disp(sprintf('Failed to open file (%s)\n',file));
    b = false;
    return
  end

  %
  % Skip to Venc Adjustment
  % Image Data Results for Slice at SP R0.6 Venc Adjustment -200 cm/sec
  %              200 cm/sec
  % 
  venc = 0.0;
  img_cnt = 0;
  while 1
    % same as fgets(line,MAX_LINE,fp) in C
    line = fgetl(fp);
    if ~ischar(line)
      break
    end
    if strncmp(line,'Image Data Results',18)
      line = search('Adjustment',line);
      if isempty(line)
        disp('Bad Format @ Venc Adjustment');
        b = false;
        return
      end
      [tok,line] = strtok(line);
      venc = sscanf(tok,'%d');
      if isempty(venc)
        disp('Bad Format @ Venc');
        b = false;
        return
      end
      if venc < 0.0, venc = -venc; end
      line = fgetl(fp);
      tok = strtok(line);
      if ~isempty(tok)
        b = false;
        return
      end
    else
      if venc > 0.0
        % Find Image Number
        tok = strtok(line);
        if isempty(tok)
          break
        else
          tok = str2num(tok);
          if tok >= 0
            if ~n
              n = 1;
            else
              n = n + 1;
            end
          end
        end
      end
    end
  end
  
  if feof(fp)
    disp('Unexpeced EOF');
    b = false;
    return
  end
  
  % Skip to Regions
  getRegs = false;
  m = 0;
  while 1
    line = fgetl(fp);
    if ~ischar(line)
      b = false;
      return
    end
    
    tok = strtok(line);
    if strncmp(tok,'Reg',3)
      getRegs = true;
      line = fgetl(fp);
    else
      if getRegs
        if isempty(tok)
          break % end of regs
        else
          m = m + 1;
          tmp_argus = textscan(line,' %f ','treatAsEmpty','------');
          if size(tmp_argus{1},1) < 1 % Ref Line, not always present, skip
            m = m - 1;
          else
            argus(m) = tmp_argus;  %#ok<AGROW>
          end
        end
      end
    end
  end
  clear getRegs;
  
  % Skip to "Flow Contours:"
  while 1
    % same as fgets(line,MAX_LINE,fp) in C
    line = fgetl(fp);
    if ~ischar(line)
      b = false;
      return
    end
    
    if strncmp(line,'Flow contours:',14)
      break
    end
  end
  
  v = cell(1,m);
  t = zeros(1,n);
  i = 0;
  while 1
    i = i + 1;
    % same as fgets(line,MAX_LINE,fp) in C
    line = fgetl(fp);
    if ~ischar(line)
      break
    end
    
    % Line #1 Series number %d, image number #, SP R11.1, TT %.1f ms
    line = search('image',line);
    if isempty(line)
      b = false;
      return
    end
    [tok,line] = strtok(line);
    if ~strncmp(tok,'number',6)
      b = false;
      return
    end
    [tok,line] = strtok(line);
    img_num = sscanf(tok,'%d');
    if isempty(img_num)
      b = false;
      return
    end
    line = search('TT',line);
    if isempty(line)
      b = false;
      return
    end
    [tok,line] = strtok(line);
    tt = sscanf(tok,'%fms');
    if isempty(tt)
      b = false;
      return
    end
    t(i) = tt;
    
    % get next line
    % expect at least one
    line = fgetl(fp);
    if ~ischar(line)
      disp('Expected at least one region for image');
      b = false;
      return
    end
    tok = strtok(line);
    j = 0;
    while ~isempty(tok)
      j = j + 1;
      [c,pos] = textscan(line,'%f: %f:');
      line = line(pos+1:length(line));
      v{j}{i} = cell(c{2});
      v{j}{i} = textscan(line,' (%f, %f) ');
      line = fgetl(fp);
      if ~ischar(line)
        break
      end
      tok = strtok(line);
    end
    b = true;
  end
% end of function

%
% search (needle, haystack)
%
function b = search(needle, haystack)
  l = length(needle);
  while ~isempty(haystack)
    [tok, haystack] = strtok(haystack);
    if strncmp(needle,tok,l)
      b = haystack;
      return
    end
  end
  b = '';
  return
%end of function