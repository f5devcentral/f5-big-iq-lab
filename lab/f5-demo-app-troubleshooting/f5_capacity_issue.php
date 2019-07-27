<!-- Page to install in hackazon container under /var/www/hackazon/web -->
<!DOCTYPE html>
<html lang='en'>
<head>
    <title>F5 App Troubleshooting Inability to handle production data capacities</title>
</head>
<body>

<?php

$filename = 'database.txt';

if (file_exists($filename)) {
	echo "The file $filename exists";
	# if file date is less than 30 sec but has value less than 10, delete it => normal condition.
	if(date("U",filectime($filename)) <= time() - 30) {
		if($n <= 10){
			# delete database
			unlink("$filename");
		}
	}
	# retreive database content
	$myfile = fopen("$filename", "r") or die("Unable to open file!");
	flock($myfile, LOCK_EX);
	$n=fgets($myfile);
	echo "<p/>Data: $n";
	flock($myfile, LOCK_UN);
	fclose($myfile);
	# increase and write in database file
	$n++;
	$myfile = fopen("$filename", 'w') or die('Cannot open file:  '.$filename);
	flock($myfile, LOCK_EX);
	fwrite($myfile, $n);
	flock($myfile, LOCK_UN);
	fclose($myfile);
} else {
	# if file does not exist, instanciate database to 1
	echo "The file $filename does not exist";
	$myfile = fopen("$filename", 'w') or die('Cannot open file:  '.$filename);
	flock($myfile, LOCK_EX);
	$n="1";
	echo "<p/>Data: $n";
	fwrite($myfile, $n);
	flock($myfile, LOCK_UN);
	fclose($myfile);
}

# If number over 20, send error 500
if($n >= 60) {
	echo "<p/>Data: $n";
	http_response_code(503);
}

# If number over 100, send error 500
if($n >= 65) {
	# delete database
	unlink("$filename");
	sleep(10);
}
?>

</body>
</html>