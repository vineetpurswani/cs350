%% ---------------------------------------------------------------------------------
%% Authors:
%% Vineet Purswani			12813
%% Ayushman Sisodiya		12188
%% Deepak Kumar 			12228
%% ---------------------------------------------------------------------------------


\insert 'Queue.oz'

declare IndexCounter

IndexCounter = {NewCell 0}

proc {Push SemanticStack Stmt Env}
	case Stmt of nil then skip
	else SemanticStack := semanticStatement(Stmt Env) | @SemanticStack end
end

fun {Pull SemanticStack}
	case @SemanticStack of nil then nil
	else 
		local Top = @SemanticStack.1 in
			SemanticStack := @SemanticStack.2
			Top
		end
	end
end

proc {AddStack Stmt Env}
	local SemanticStack = {NewCell nil} in
		{Push SemanticStack Stmt Env}
		{QueuePut stack(SemanticStack ready @IndexCounter)}
		{Browse 'Adding Thread'#@IndexCounter}
		IndexCounter := @IndexCounter+1
	end
end

fun {TopExecutableStack}
	% if {QueueIsEmpty} == true
	% then raise terminate() end
	% else
	local Helper Helper1 in
		fun {Helper}
			case {QueueTop}
			of stack(TempStack ready Index) then {Browse 'Starting Thread'#Index} TempStack|nil
			% Check for suspended threads if they are ready to execute
			[] stack(TempStack suspend#X Index) then
				case {RetrieveFromSAS X}
				of equivalence(_) then {QueueGet}|{Helper}
				else {Browse 'Starting Thread'#Index} TempStack|nil
				end
			else {QueueGet}|{Helper}
			end
		end
		fun {Helper1 Array}
			case Array
			of X|nil then X
			[] H|T then {QueuePut H} {Helper1 T}
			end
		end
		{Helper1 {Helper}}	
	end
	% end
end

proc {GetPutEmptyStack}
	case {QueueGet} 
	of stack(TempStack _ Index) 
	then 
		% {QueuePut stack(TempStack empty Index)} 
		{Browse 'Thread'#Index#' suspended. Reason - Empty Stack.'}
	end
end

proc {GetPutSuspendedStack V X}
	case {QueueGet} 
	of stack(TempStack _ Index) 
	then 
		{QueuePut stack(TempStack suspend#V Index)} 
		{Browse 'Thread'#Index#' suspended. Reason - Unbound variable'#X#'encountered.'}
	end
end
