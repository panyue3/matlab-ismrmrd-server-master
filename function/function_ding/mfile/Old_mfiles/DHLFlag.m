function [DHLMask, flaglist] = DHLFlag(value)

% #define DHL_ACQUISITION_END       SET_BIT_AT(0)  // set by RT, the follows set by sequence
DHLMask.DHL_ACQUISITION_END         = bitand(value, 2^0);
% #define DHL_FIRST_LINE_ACQ        SET_BIT_AT(1)
DHLMask.DHL_FIRST_LINE_ACQ          = bitand(value, 2^1);
% #define DHL_LAST_LINE_ACQ         SET_BIT_AT(2)
DHLMask.DHL_LAST_LINE_ACQ           = bitand(value, 2^2);
% #define DHL_FIRST_LINE_SLICE      SET_BIT_AT(3)
DHLMask.DHL_FIRST_LINE_SLICE        = bitand(value, 2^3);
% #define DHL_LAST_LINE_SLICE       SET_BIT_AT(4)
DHLMask.DHL_LAST_LINE_SLICE         = bitand(value, 2^4);
% #define DHL_FIRST_LINE_SECTION    SET_BIT_AT(5)
DHLMask.DHL_FIRST_LINE_SECTION      = bitand(value, 2^5);
% #define DHL_LAST_LINE_SECTION     SET_BIT_AT(6)
DHLMask.DHL_LAST_LINE_SECTION       = bitand(value, 2^6);
% #define DHL_PHASE_CORRECTION      SET_BIT_AT(7)
DHLMask.DHL_PHASE_CORRECTION        = bitand(value, 2^7);
% #define DHL_READOUT_REVERSION     SET_BIT_AT(8)  // set kx acquisition direction flag in EPI
DHLMask.DHL_READOUT_REVERSION       = bitand(value, 2^8);
% #define DHL_PPA_REFLINE           SET_BIT_AT(9)
DHLMask.DHL_PPA_REFLINE             = bitand(value, 2^9);
% #define DHL_FEEDBACK              SET_BIT_AT(10)
DHLMask.DHL_FEEDBACK                = bitand(value, 2^10);
% #define DHL_FIRST_LINE_SPE        SET_BIT_AT(11)
DHLMask.DHL_FIRST_LINE_SPE          = bitand(value, 2^11);
% #define DHL_LAST_LINE_SPE         SET_BIT_AT(12)
DHLMask.DHL_LAST_LINE_SPE           = bitand(value, 2^12);
% #define DHL_NOISE_SCAN            SET_BIT_AT(24)
DHLMask.DHL_NOISE_SCAN              = bitand(value, 2^24);
% % #define DHL_SEQUENCE_STOP         SET_BIT_AT(63)
% DHLMask.DHL_SEQUENCE_STOP           = bitand(value, 2^63);

flaglist = '';

if DHLMask.DHL_ACQUISITION_END            
  flaglist = [flaglist ' DHL_ACQUISITION_END           '];
end
if DHLMask.DHL_FIRST_LINE_ACQ            
  flaglist = [flaglist ' DHL_FIRST_LINE_ACQ           '];
end
if DHLMask.DHL_LAST_LINE_ACQ            
  flaglist = [flaglist ' DHL_LAST_LINE_ACQ           '];
end
if DHLMask.DHL_FIRST_LINE_SLICE            
  flaglist = [flaglist ' DHL_FIRST_LINE_SLICE           '];
end
if DHLMask.DHL_LAST_LINE_SLICE            
  flaglist = [flaglist ' DHL_LAST_LINE_SLICE           '];
end
if DHLMask.DHL_FIRST_LINE_SECTION            
  flaglist = [flaglist ' DHL_FIRST_LINE_SECTION           '];
end
if DHLMask.DHL_LAST_LINE_SECTION            
  flaglist = [flaglist ' DHL_LAST_LINE_SECTION           '];
end
if DHLMask.DHL_PHASE_CORRECTION            
  flaglist = [flaglist ' DHL_PHASE_CORRECTION           '];
end
if DHLMask.DHL_READOUT_REVERSION            
  flaglist = [flaglist ' DHL_READOUT_REVERSION           '];
end
if DHLMask.DHL_PPA_REFLINE            
  flaglist = [flaglist ' DHL_PPA_REFLINE           '];
end
if DHLMask.DHL_FEEDBACK            
  flaglist = [flaglist ' DHL_FEEDBACK           '];
end
if DHLMask.DHL_FIRST_LINE_SPE            
  flaglist = [flaglist ' DHL_FIRST_LINE_SPE           '];
end
if DHLMask.DHL_LAST_LINE_SPE            
  flaglist = [flaglist ' DHL_LAST_LINE_SPE           '];
end
if DHLMask.DHL_NOISE_SCAN            
  flaglist = [flaglist ' DHL_NOISE_SCAN           '];
end
% if DHLMask.DHL_SEQUENCE_STOP            
%   flaglist = [flaglist ' DHL_SEQUENCE_STOP           '];
% end