use v5.26;
use warnings;
use Switch;
use DBIx::Simple;

sub main_menu {
  print ("1. Log in.\n");
  print ("2. Exit\n");
  print ("Input command: ");
}

sub main_menu_logged_in {
  print ("1. Log out.\n");
  print ("2. Add a new user.\n");
  print ("3. Exit.\n");
  print ("Input command: ");
}

sub valid_username {
  my ($username) = @_;
  return (length $username >= 1) && ($username =~ /^[a-zA-Z][a-zA-Z0-9_]*$/);
}

sub valid_password {
  my ($password) = @_;
  return (length $password >= 6) && ($password =~ /^[a-zA-Z0-9_]+$/)
    && ($password =~ /[a-z]+/) && ($password =~ /[A-Z]+/)
    && ($password =~ /[0-9]+/);
}

sub get_user {
  my ($pair) = @_;
  my @tokens = split / /, $pair;
  if (scalar @tokens != 2) {
    die "Corrupted file!";
  }
  return @tokens;
}

sub request_credentials {
  print "Input username: ";
  my $username = <>;
  chomp $username;

  print "Input password: ";
  my $password = <>;
  chomp $password;

  return ($username, $password);
}

sub login_user_file {
  my ($filename) = @_;
  my ($username, $password) = request_credentials();

  #search for user in file
  open(my $fh, '<:encoding(UTF-8)', $filename)
     or die "Could not open file '$filename' $!";
  my $found = 0;
  while (my $row = <$fh>) {
    chomp $row;
    my ($user, $passwd) = get_user($row);
    if (($user eq $username) and ($passwd eq $password)) {
      $found = 1;
    }
  }
  close $fh;

  return $found;
}

sub login_user_db {
  my ($username, $password) = request_credentials();

  my $db = DBIx::Simple->connect('DBI:Pg:dbname=task1', 'maria', 'maria');
  my $result = $db->query("SELECT COUNT(*) FROM Users WHERE username = '$username'
                    AND password = '$password'")->list;

  $db->disconnect();
  return $result;
}

sub save_user_file {
  my ($filename, $username, $password) = @_;
  open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
  say $fh "$username $password";
  close $fh;
}

sub save_user_db {
  my ($username, $password) = @_;

  my $db = DBIx::Simple->connect('DBI:Pg:dbname=task1', 'maria', 'maria');
  $db->query("INSERT INTO users VALUES(?, ?)", $username, $password);
  $db->disconnect();
}

sub add_user {
  my ($filename) = @_;
  my ($username, $password) = request_credentials();

  if (not valid_username($username)) {
    print "Invalid username!\n";
    return;
  }

  if (not valid_password($password)) {
    print "Invalid password!\n";
    return;
  }

  save_user_db($username, $password);
}

sub main {
    my $filename = "login.txt";
    my $logged_in = 0;
    my $exit = 0;
    while (not $exit) {
        if (!$logged_in) {
          main_menu();
          my $option = <>;
          chomp $option;

          switch ($option) {
            case 1 {
                my $found = login_user_db($filename);
                if ($found) {
                  print ("Logged in!\n");
                  $logged_in = 1;
                }
                else {
                  print ("Invalid username or password!\n");
                }
            }
            case 2 {
              $exit = 1;
            }
            else {print ("Invalid option!\n");}
          }
        }
        else {
          main_menu_logged_in();
          my $option = <>;
          chomp $option;

          switch ($option) {
            case 1 {
              print ("Logged out!\n");
              $logged_in = 0;
            }
            case 2 {
              add_user($filename);
            }
            case 3 {
              $exit = 1;
            }
            else {
              print ("Invalid option!\n");
            }
          }
        }
    }
}

main();
