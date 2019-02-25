use v5.26;
use warnings;
use DBIx::Simple;

my $db = DBIx::Simple->connect('DBI:Pg:dbname=task1', 'maria', 'maria');
#$db->query("CREATE TABLE Users (username VARCHAR(50) PRIMARY KEY,
#  password VARCHAR(50))");
#$db->query("INSERT INTO Users VALUES('maria', 'Mariaa1')");
