% Student exercise profile
:- set_prolog_flag(occurs_check, error).        % disallow cyclic terms
:- set_prolog_stack(global, limit(8 000 000)).  % limit term space (8Mb)
:- set_prolog_stack(local,  limit(2 000 000)).  % limit environment space

% Your program goes here

% Facts about registered people and their informations:
% name, a list of three passions maximum, their age and their town.

person(chiara,[cooking,food,theatre],21,casoria).
person(simone,[cooking,food,dancing],20,ponticelli).
person(maria,[theatre,music,books],23,casavatore).
person(antonella,[cooking,music,books],56,roma).
person(luca,[food,theatre,gardening],40,casoria).

%Facts that link people to a profile used for login:
%Person name, username, password.

account(chiara,ladivina,111).
account(simone,monxis_v,12345).
account(maria,the_strangest,2222).
account(antonella,fragola86,333).
account(luca,predator,gianniluca).

% Facts about connections between cities:
% first city, second city and distance between them in kilometers.

link(casoria,casoria,0).
link(casavatore,casavatore,0).
link(ponticelli,ponticelli,0).
link(casoria,ponticelli,9).
link(casavatore,casoria,19).
link(casavatore,ponticelli,11).
link(roma,casoria,219).
link(roma,casavatore,220).

% Rules that exchange the order of the cities:
% X is the first town, Y the second one and C is the distance.
% Not is required in order to avoid match duplicates with people
% with the same city.

linking(X,Y,C):-link(X,Y,C),not(X=Y).
linking(X,Y,C):-link(Y,X,C).

% Rules for arithmetic operations, in particular addiction and subtraction:
% subtraction between people's ages and addiction to find the score of the match.
% Res is the result of the operation, A is the first operand and B the second one.

find_res(Res,A,B):-Res is A-B.
find_res2(Res,A,B):-Res is A+B.

% Rules for absolute value calculation, used to calculate age difference.
% The first rule is for positive values of Res while the second rule 
% is for negative values of Res. 
% Result is the value obtained after the absolute value operation.
abs(Res,Res):-Res >= 0.
abs(Res,Result):-
    Res < 0, 
    Result is -Res.

% Rule that allows to compare people ages, performing a subtraction 
% between ages and then calculating its absolute value.
% Result is the absolute value of the age difference,
% Personsage1 and Personsage2 are people's ages.
compare_age(Result,Personsage1,Personsage2):-
        find_res(Difference,Personsage1,Personsage2),
        abs(Difference,Result).

% Rule that allows to check if a number C is between A and B.
including(A,B,C):-
    C>=A,
    C=<B.

% Rule that allows to check if a number A is bigger than B.
major(A,B):-A>B.

% Rules that set a first value for the score based on the age difference.
% There are three rules, each one manages a different case, 
% with a different number of points: if the age difference is 
% between 0 and 4, then the ages are ok and the match will have 
% the maximum number of points (concerning the age), otherwise 
% if the difference is between 5 and 10, the match will have less points. 
% The last case concerns an age difference of more than 11 years where 
% the match will have be very few points. 
% Personsage1 and Personsage2 are people's ages and X are the points obtained
% after the execution of the rule.
age_ok(Personsage1,Personsage2,X):-
    compare_age(Result,Personsage1,Personsage2),
    including(0,4,Result),
    X=30.
age_half_ok(Personsage1,Personsage2,X):-
    compare_age(Result,Personsage1,Personsage2),
    including(5,10,Result),
    X=15.
age_not_ok(Personsage1,Personsage2,X):-
    compare_age(Result,Personsage1,Personsage2),
    major(Result,11),
    X=5.

% Rules that allows to understand the distance between people based
% on the town where they live.
% There are three rules: the first one check if the distance is 
% between 0 and 20 kilometres and in this case the match will have 
% the maximum number of points. If distance is between 21 and 40 
% kilometers, the match will have less points; insted the last rule manage 
% the case in which the distance is bigger than 41 kilometers and the 
% match will have the lowest score. The score is calculated by adding the 
% age points to the parzial score calculated by age rules.
% City1 and City2 are the town where the two people live, X are the
% points accumulated until now and Y are the new score.
km_ok(City1,City2,X,Y):-
    linking(City1,City2,Distanza),
    including(0,20,Distanza),
    Y=X+25.
km_half_ok(City1,City2,X,Y):-
    linking(City1,City2,Distanza),
    including(21,40,Distanza),
    Y=X+15.
km_not_ok(City1,City2,X,Y):-
    linking(City1,City2,Distanza)
    ,major(Distanza,41),
    Y=X+10.

% Rules that allows to assign point according to the passions that two
% people have in common: if they have all the passions of their list 
% in common, the match will have the maximum number of points. 
% For every passion not in common the match will have less points.
% The first constant number is the number of passions in common, Y are the
% point accumulated until now and Score is the final score.
score(3,Y,Score):-find_res2(Score,Y,45).
score(2,Y,Score):-find_res2(Score,Y,30).
score(1,Y,Score):-find_res2(Score,Y,15).
score(0,Y,Score):-find_res2(Score,Y,0).

% Rule that calculates the len of a list using recursion. It is
% used to calculate the len of the intersection list that is the 
% number of passions that people have in common.
len([],0).
len([_Head|Tail],N):- 
    len(Tail,NUM1),
    plus(NUM1,1,N).

% Rule that shows on screen a message with the final score of the match.
% Score is the final score, "nl" stands for new line.
explain(X,Y,Score):-
    write('Between '),
    write(X), 
    write(' and '), 
    write(Y), 
    write(' the match is '), 
    write(Score), 
    write("%"), 
    nl.
    
%Starting interface
start:-
    writeln('Welcome to JoinMEet'),
    login.

%Rules that reads the password in input and checks if the password is associated with the account found by accout_exists
%X is the password
password(X):-
    read(X),
    account(_Y,_Z,X).

%Rule that checks if the username entered by the user is associated with an account
%Person is the name of the person, Username is the username, Password is the password
account_exists(Person,Username,Password):-account(Person,Username,Password).

%Rule for login. The system asks the user to enter his username and checks if the username exists. If the username exists, the system asks the user to enter the password and if this check is successful, a welcome message is displayed followed by a list of compatible people. Otherwise, an error message is displayed and processing ends.
login:-
    writeln('Enter your username'),
    read(Username),
    (   account_exists(Person,Username,Password) ->  
    		writeln('Enter your password'),
        	(   password(Password) ->  
					write('Welcome '), write(Username),nl,
        			matchmaking(Person,X,Score),
        			explain(Person,X,Score)
            ;   writeln("We're sorry, the password you entered is incorrect, try again"),
        		fail
            )
    ;   writeln("We're sorry, your account is not in the system"),
        fail
    ).
      
% Following there are all the matchmaking rules in OR between them
% (using horn clause) to manage all possible combination (age_ok
% with km_ok, age_ok with km_half_ok and so on).
% person1 and person2 are the names of two candidates and Score 
% shows at the end the points calculated. 
% The rule first considers two people with their informations;
% then the operator "not" is used to avoid that one person matches 
% with herself/himself.
% The number of passion in common is calculated using the 
% intersection between the passions lists (first and second 
% parameter of the intersection instruction) of the two people. 
% The intersection creates a new list (third parameter: Intersezione) 
% with only the passions in common between two people and then the 
% system calculates its len with the rule len. Next, using the score rule, 
% the system calculates the match value adding points.
% Person1 and Person2 are the name of the two people, Score is the value
% of the points accumulated during the calculation of the score.

matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_ok(Eta1,Eta2,X),
    km_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).

matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_half_ok(Eta1,Eta2,X),
    km_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).
   
matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_not_ok(Eta1,Eta2,X),
    km_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).
  
matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_ok(Eta1,Eta2,X),
    km_half_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).
  
matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_ok(Eta1,Eta2,X),
    km_not_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).
 
matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_half_ok(Eta1,Eta2,X),
    km_half_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).
   
matchmaking(Person1,Person2,Score):-
    person(Person1,[P1,P2,P3],Eta1,City1),
    person(Person2,[P4,P5,P6],Eta2,City2),
    not(Person1=Person2),
    age_not_ok(Eta1,Eta2,X),
    km_not_ok(City1,City2,X,Y),
    intersection([P1,P2,P3],[P4,P5,P6],Intersezione),
    len(Intersezione,N),
    score(N,Y,Score).

/** <examples> Your example queries go here, e.g.
 
?-matchmaking(chiara,X,Y)
This query lists people matching with "chiara" and the relative score.

?-matchmaking(X,Y,Z)
This query shows all possible relationships between people 
registered to the application with the relative score.

?-matchmaking(X,Y,100)
This query show sall the relationship with a score of 100 points,
the maximum score.
*/


