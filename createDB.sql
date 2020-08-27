/*  
Inspired from COMP3311
Creating relational schema based on ER Model with Oracle SQL
*/

clear screen
set feedback off
set heading off
select '*** Creating Task 2 database ***' from dual;
set heading on

-- Clean the database

drop table Discussion;
drop table Review;
drop table Assigned;
drop table Prefers;
drop table AuthorOf;
drop table Submission;
drop table PCChair;
drop table PCMember;
drop table Person;

-- Create the tables
create table Person(
    personId    smallint        primary key,
    username    char(10)        default null,
    title       char(5),
    name        varchar2(50),
    institution varchar2(100),
    country     varchar2(30),
    email       varchar2(50),
    
    -- constraint title to be Mr, Ms, Miss, Dr, Prof; default is null
    constraint PersonTitle check(title in ('Mr', 'Ms', 'Miss', 'Dr', 'Prof')),
    -- constraint unique email
    constraint UniqueEmail unique(email),
    -- constraint username's length is minimum 3 and maximum 10 lowercase letters; default is null
    constraint OnlyLowercaseUsername check(regexp_like(username, '^[a-z]{3,10}\s*$')),
    -- constraint unique username
    constraint UniqueUsername unique(username));

create table PCMember(
    personId    smallint    primary key,
    
    -- inherited from Person
    constraint PCMemberForeign foreign key (personId) references Person(personId) on delete cascade);
    
create table PCChair(
    personId    smallint    primary key,
    
    --inherited from PCMember
    constraint PCChairForeign foreign key (personId) references PCMember(personId) on delete cascade);
    
create table Submission(
    submissionNo    smallint        primary key,
    title           varchar2(100)   default null,
    abstract        varchar2(300),
    submissionType  varchar2(20)    default 'research',
    status          varchar2(9)     default null,
    contactAuthor   smallint,
    
    -- constraint submissionType to be demo, industrial, research, vision; default is research
    constraint SubmissionType check(submissionType in ('demo', 'industrial', 'research', 'vision')),
    -- constraint status to be accept, reject, withdrawn; default is null
    constraint SubmissionStatus check(status in ('accept', 'reject', 'withdrawn')),
    
    -- for the "ContactFor" relation
    constraint SubmissionForeign foreign key (contactAuthor) references Person(personId) on delete cascade);

create table AuthorOf(
    submissionNo    smallint,
    personId        smallint,
    primary key (submissionNo, personId),
    
    -- between Submission and Person
    constraint AuthorOfForeign1 foreign key (submissionNo) references Submission(submissionNo) on delete cascade,
    constraint AuthorOfForeign2 foreign key (personId) references Person(personId) on delete cascade);
    
create table Prefers(
    submissionNo    smallint,
    personId        smallint,
    preference      smallint    default null,
    primary key(submissionNo, personId),
    
    -- constraint preference to be 1,2,3,4,5; default is null
    constraint Prefer1To5 check(preference in (1,2,3,4,5)),
    
    -- between Submission and PCMember
    constraint PrefersForeign1 foreign key (submissionNo) references Submission(submissionNo) on delete cascade,
    constraint PrefersForeign2 foreign key (personId) references PCMember(personId) on delete cascade);

create table Assigned(
    submissionNo    smallint,
    personId        smallint,
    primary key (submissionNo, personId),
    
    -- between Submission and PCMember
    constraint AssignedForeign1 foreign key (submissionNo) references Submission(submissionNo) on delete cascade,
    constraint AssignedForeign2 foreign key (personId) references PCMember(personId) on delete cascade);

create table Review(
    submissionNo            smallint,
    personId                smallint,
    
    relevant                char(1) not null,
    technicallyCorrect      char(1) not null,
    lengthAndContent        char(1) not null,
    
    confidence              number(2,1) not null,
    
    originality             smallint not null,
    impact                  smallint not null,
    presentation            smallint not null,
    technicalDepth          smallint not null,
    overallRating           smallint not null,
    
    mainContribution        varchar2(300),
    strongPoints            varchar2(300),
    weakPoints              varchar2(300),
    overallSummary          varchar2(300),
    detailedComments        varchar2(1000),
    confidentialComments    varchar2(300),
    primary key (submissionNo, personId),
    
    -- constraints as mentioned in Appendix A
    -- relevant, technicallyCorrect, lengthAndContent to be Y/N/M, default null
    constraint RelevantYNM check(relevant in('Y','N','M')),
    constraint TechnicallyCorrectYNM check(technicallyCorrect in('Y','N','M')),
    constraint LengthAndContentYNM check(lengthAndContent in('Y','N','M')),
    
    -- confidence between 0.5 and 1
    constraint ConfidenceHalfTo5 check(confidence between 0.5 and 1),
    
    -- originality, impact, presentation, technicalDepth, overallRating between 1 and 5
    constraint Originality1To5 check(originality in (1,2,3,4,5)),
    constraint Impact1To5 check(impact in (1,2,3,4,5)),
    constraint Presentation1To5 check(presentation in (1,2,3,4,5)),
    constraint TechnicalDepth1To5 check(technicalDepth in (1,2,3,4,5)),
    constraint Rating1To5 check(overallRating in (1,2,3,4,5)),
    
    -- between Submission and PCMember
    constraint ReviewForeign1 foreign key (submissionNo) references Submission(submissionNo) on delete cascade,
    constraint ReviewForeign2 foreign key (personId) references PCMember(personId) on delete cascade);

create table Discussion(
    sequenceNo      smallint,
    submissionNo    smallint,
    personId        smallint,
    comments        varchar2(200),
    primary key (sequenceNo, submissionNo, personId),
    
    -- between Submission and PCMember
    constraint DisucssionForeign1 foreign key (submissionNo) references Submission(submissionNo) on delete cascade,
    constraint DiscussionForeign2 foreign key (personId) references PCMember(personId) on delete cascade);

/* Write data to the disk */
commit;

set feedback off
set heading off
select '*** Task 2 database created  ***' from dual;
set heading on
