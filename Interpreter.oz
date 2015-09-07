\insert 'Unify.oz'
% \insert 'SingleAssignmentStore.oz'

% functor
% import
% 	Browser(browse:Browse)

declare SemanticStack Store Environment

SemanticStack = {NewCell nil} 
Store = {NewDictionary}
% SASCounter = {NewCell 0}
Environment = environment()

proc {Push Stmt Env}
	case Stmt of nil then skip
	else SemanticStack := semanticStatement(Stmt Env) | @SemanticStack end
end

fun {Pull}
	case @SemanticStack of nil then nil
	else 
		local Top = @SemanticStack.1 in
			SemanticStack := @SemanticStack.2
			Top
		end
	end
end

% fun {NextSASCounter}
% 	local C = @SASCounter in
% 		SASCounter := @SASCounter+1
% 		C
% 	end
% end

proc {Interpreter}
	{Browse @SemanticStack}
	case @SemanticStack of nil then skip
	else 
		case {Pull} of semanticStatement([nop] E) then 
			skip
		[] semanticStatement([localvar ident(X) S] E) then
			{Push S {Adjoin E environment(X:{AddKeyToSAS})}}
		[] semanticStatement([bind ident(X) ident(Y)] E) then
			{Unify ident(X) ident(Y) E}
		[] semanticStatement([bind ident(X) V] E) then
			% {BindValueToKeyInSAS E.X V}
			% case V of literal(_) then {Unify ident(X) V E}
			% skip
			{Unify ident(X) V E}
		[] semanticStatement(S1|S2 E) then 
			{Push S2 E}
			{Push S1 E}
		else skip end
		{Interpreter}
	end
end

{Push 
[localvar ident(foo)
  [localvar ident(bar)
   [[bind ident(foo) [record literal(person) [literal(name) ident(bar)]]]
    [bind ident(bar) [record literal(person) [literal(name) ident(foo)]]]
    [bind ident(foo) ident(bar)]]]] Environment}
{Interpreter}
{Browse {Dictionary.entries SAS}}
% end

