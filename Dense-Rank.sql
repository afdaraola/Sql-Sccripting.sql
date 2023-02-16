/*
  Example:
Our database has a table named championship with data in the following columns: id (primary key), user_name, and score.

id	user_name	score
111	John	12
112	Mary	23
115	Lisa	45
120	Alan	23
221	Chris	23
Let’s display all users’ names and their scores sorted in descending order and ranked by

  */

-- Example case create statement:
CREATE TABLE championship (
                          id INTEGER NOT NULL PRIMARY KEY,
                          user_name varchar2(200) NOT NULL,
                          score integer NOT NULL
);

INSERT INTO championship(id, user_name, score) VALUES(111, 'John', 12);
INSERT INTO championship(id, user_name, score) VALUES(112, 'Mary', 23);
INSERT INTO championship(id, user_name, score) VALUES(115, 'Lisa', 45);
INSERT INTO championship(id, user_name, score) VALUES(120, 'Alan', 23);
INSERT INTO championship(id, user_name, score) VALUES(221, 'Chris', 23);



  --- ranking skips positions after rows with the same rank
    select  user_name, score, RANK() over ( order by score desc ) as rank_place
    from championship;

 --Dense ranking doesn't skip positions after rows with the same rank
  select  user_name, score, Dense_RANK() over ( order by score desc ) as rank_place
    from championship

