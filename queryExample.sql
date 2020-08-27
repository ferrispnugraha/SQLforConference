/*  
Inspired from COMP3311
SQL to process query based on requirements and constraints
*/


/*
    1. For each submission that does not have any PC member assigned to it and that is available for assignment,
       find the title, submission type, and contact author name and email. Order the result by submission type
       ascending.
*/

set heading off
select 'Query 1: For each submission that does not have any PC member assigned to it and that is available for assignment,
         find the title, submission type, and contact author name and email. Order the result by submission type
         ascending.' from dual;
set heading on

with temp(submissionNo, submissionTitle, submissionType, personId, contactAuthor) as -- personId is the assigned PCMember
(   select submissionNo, title, submissionType, personId, contactAuthor
    from Submission natural left outer join Assigned
    where status <> 'withdrawn')                                    -- not withdrawn submission

select submissionTitle, submissionType, name, email
from temp join Person on (temp.contactAuthor = Person.personId)     -- to link contactAuthor to find his/her email and name
group by submissionNo, submissionTitle, submissionType, name, email
having count(temp.personId) = 0                                    -- no PCMember is assigned
order by submissionNo asc;

/*
    2. Find the submission number, title, and names of all the authors, for those submissions that have at least one
       PC member as an author. Order the result by submission number ascending.
*/

set heading off
select '------------------------------------------------------------------------------------------------------' from dual;
select 'Query 2: Find the submission number, title, and names of all the authors, for those submissions that have at least one
         PC member as an author. Order the result by submission number ascending.' from dual;
set heading on
    
select submissionNo, title, name
from  AuthorOf natural join Person
where submissionNo in (select submissionNo
                        from Submission natural join AuthorOf natural join PCMember)  --if exist after natural join, at least an author is PCMember
order by submissionNo asc;


/*
    3. For each PC member, find the PC member name and the number of submissions for which he/she has
       specified a preference. Order the result by number of submissions descending.
*/

set heading off
select '------------------------------------------------------------------------------------------------------' from dual;
select 'Query 3: For each PC member, find the PC member name and the number of submissions for which he/she has
         specified a preference. Order the result by number of submissions descending.' from dual;
set heading on

with result(personId, SubmissionCount) as 
(   select personId, count(submissionNo)
    from PCMember natural join Prefers
    where preference between 1 and 5
    group by personId)

select name, SubmissionCount
from result natural join Person
order by SubmissionCount desc;

/*
    4. For those PC members who have not indicated a preference of 3 or greater for any submission, find the PC
       member name as well as the submission number, title and preference of the submissions for which they
       have indicated a preference. Order the result first by PC member name in ascending order and then by
       preference for a submission in descending order.
*/

set heading off
select '------------------------------------------------------------------------------------------------------' from dual;
select 'Query 4: For those PC members who have not indicated a preference of 3 or greater for any submission, find the PC
         member name as well as the submission number, title and preference of the submissions for which they
         have indicated a preference. Order the result first by PC member name in ascending order and then by
         preference for a submission in descending order.' from dual;
set heading on

with recap(personId, submissionNo, SubmissionTitle, preference) as
(   select personId, submissionNo, title, preference
    from PCMember natural join Prefers natural join Submission)

select name, submissionNo, SubmissionTitle, preference
from recap natural join Person
where personId not in (select personId
                       from recap
                       where preference >= 3)
order by name asc, preference desc;

/*
    5. For each submission that has at least three reviews, find the title, submission type, PC member name, overall
       rating and spread where the spread is 1.0 or greater. Order the result by submission number.
*/

set heading off
select '------------------------------------------------------------------------------------------------------' from dual;
select 'Query 5: For each submission that has at least three reviews, find the title, submission type, PC member name, overall
         rating and spread where the spread is 1.0 or greater. Order the result by submission number.' from dual;
set heading on

with spreadRecap(submissionNo, submissionTitle, submissionType, ReviewNumber, Spread) as 
(   select submissionNo, title, submissionType, count(*), max(overallRating)- min(overallRating)
    from Submission natural join Review
    group by submissionNo, title, submissionType)
    
select submissionTitle, submissionType, name, overallRating, Spread
from spreadRecap natural join Review natural join Person
where submissionNo in (select submissionNo
                        from spreadRecap
                        where ReviewNumber >= 3
                        and Spread >= 1.0)
order by submissionNo;
