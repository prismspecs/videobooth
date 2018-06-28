<?php

sleep(1);

require_once "PHPMailer/PHPMailerAutoload.php";
include 'credentials.php';

$mail = new PHPMailer;


//Enable SMTP debugging. 
//$mail->SMTPDebug = 3;                               
//Set PHPMailer to use SMTP.
$mail->isSMTP();            
//Set SMTP host name
$mail->Host = $smtp_host;
//Set this to true if SMTP host requires authentication to send email
$mail->SMTPAuth = true;                          
//Provide username and password     
$mail->Username = $smtp_user;                 
$mail->Password = $smtp_pass;                           
//If SMTP requires TLS encryption then set it
$mail->SMTPSecure = "tls";                           
//Set TCP port to connect to 
$mail->Port = 587;

$mail->From = "party@alexandisa.com";
$mail->FromName = "Isa and Alex";

$recipient = $_GET["email"];

echo $recipient;

$mail->addAddress($recipient, "Wedding Guest");

// second argument is whatever we wanna rename the file for the recipient
$vidfilename = $_GET["file"];

//$mail->addAttachment($vidfilename, "dellpowered.mp4");
// same for gif
$mail->addAttachment($vidfilename, $vidfilename);       

$mail->isHTML(true);

$mail->Subject = "Your Isa & Alex wedding GIF is ready`";
$mail->Body = "Celebrating ...";
$mail->AltBody = "Celebrating ...";

if(!$mail->send()) 
{
    echo "Mailer Error: " . $mail->ErrorInfo;
} 
else 
{
    echo $_GET["file"]."Message sent successfully";
}