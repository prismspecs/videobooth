<html>

<head>
    <meta http-equiv="Content-Type" content="text/html">
    <title>Isa & Alex</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <link href="https://fonts.googleapis.com/css?family=Domine" rel="stylesheet">
    <style type="text/css">
    body {
        margin: 0 auto 20px;
        padding: 0;
        background: #fff;
        text-align: center;
        background-color: #3f896d;
        font-family: 'Domine', serif;
    }

    #container {
        width: 90%;
        max-width: 600px;
        margin: 0 auto;
    }

    a {
        color: #fff;
        font-weight: bold;
    }
    a:focus {
        outline: none;
    }

    .clip-container {

    }

    .gif, video {
        width: 100%; 
        height: auto;
    }

    .emaillink {
        position: relative;
        top: -50px;
        right: 16px;
        float: right;
        width: 20%;
    }

    #popover {
        padding: 10px;
        position: fixed;
        top: 40%;
        left: 25%;
        width: 50%;
        height: 20%;
        background-color: #d0c9b6;
        display: none;
    }

    @media screen and (max-width: 600px) {
    	#container {
        width: 100%;
        
    }
    }
    </style>
</head>

<body>
    <div id="container">
        <img src="logo.png" style="float:none;top:0px;margin-top:40px;margin-bottom:40px;width:80%">
        <?php
function mtimecmp($a, $b) {
        $mt_a = filemtime($a);
        $mt_b = filemtime($b);

        if ($mt_a == $mt_b)
            return 0;
        else if ($mt_a < $mt_b)
            return -1;
        else
            return 1;
    }

    $images = glob($dirname."*.mp4");
    usort($images, "mtimecmp");
    $images=array_reverse($images);

if($_GET){
$thisStart = $_GET["start"];
} 
if(!$_GET){
$thisStart = 0;
} 

//$count
$fileLimit = 7;

for ($i = $thisStart; $i < $thisStart + $fileLimit; $i++) {

    // echo $images[$i];
    // echo '<img src="'.$images[$i].'">';

    echo '<div class="clip-container">';
    

    if($images[$i] == null) break;

    // echo '<img src="'.$images[$i].'" class="gif">';

    echo '<video autoplay loop controls>';
    echo '<source src="'.$images[$i].'" type="video/mp4">';
    echo '</video>';

    //echo '<a href="download.php?file='.$images[$i].'">';
    echo '<a onclick=\'emailGif("'.$images[$i].'")\' href="javascript:void(0);">';

    echo '<img src="email.png" class="emaillink"></a>';

    echo '</div>';

    echo '<br><br>';
    
}

$nextPage = $thisStart + $fileLimit;

echo '<a href="index.php?start='.$nextPage.'"> Next Page </a>';


?>
    </div>
    <div id="popover">
        <p>What's your e-mail address?
            <p>
                <input type="text" name="emailaddress" size="35">
                <p><a onclick='sendGif()' href="javascript:void(0);">Send!</a>
                    <p><a onclick='goBack()' href="javascript:void(0);">Back</a>
    </div>
    <script>
    var currentFile = "";
    // handles the click event, sends the query
    function emailGif(fileName) {
        currentFile = fileName;
        $("#popover").fadeIn("slow", function() {
            // Animation complete
        });


    }

    function sendGif() {
        $("#popover").fadeOut("slow");
        var emailAddress = document.getElementsByName("emailaddress")[0].value;
        $.get('mailsmtp.php?file=' + currentFile + '&email=' + emailAddress, function(data) {
            alert(data);
            //alert('mailsmtp.php?file=' + currentFile + '&email=' + emailAddress);

        });
    }

    function goBack() {
        $("#popover").fadeOut("slow", function() {
            // Animation complete
        });
    }


    var time = new Date().getTime();
    $(document.body).bind("mousemove keypress", function(e) {
        time = new Date().getTime();
    });

    function refresh() {
        if (new Date().getTime() - time >= 60000)
            window.location.reload(true);
        else
            setTimeout(refresh, 10000);
    }

    setTimeout(refresh, 10000);
    </script>
</body>

</html>