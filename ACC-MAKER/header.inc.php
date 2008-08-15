<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="Author" content="nicaw" />
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<title><?php echo $ptitle?></title>
<link rel="stylesheet" href="default.css" type="text/css" media="screen" />
<link rel="stylesheet" href="screen.php" type="text/css" media="screen" />
<link rel="stylesheet" href="print.css" type="text/css" media="print" />
<link rel="alternate" type="application/rss+xml" title="News" href="news.php?RSS2" />
<script language="javascript" type="text/javascript" src="js.js"></script>
<link rel="shortcut icon" href="ico/favicon.ico" />
<?php if ($cfg['secure_session'] && !empty($_SESSION['account']) && empty($_COOKIE['remember'])){?>
<script language="javascript" type="text/javascript">
//<![CDATA[
	function tick()
	{
		ticker++;
		if (ticker > <?php echo $cfg['timeout_session'];?>){
			self.window.location.href = 'login.php?logout&redirect=account.php';
		}else{
			setTimeout ("tick()",1000);
		}
	}
	ticker = 0;
	tick();
//]]>
</script>
<?php }?>
</head>
<body>
<div id="form"></div>
<div id="container">
<div id="header"><div id="server_name"><?php echo $cfg['server_name']?></div></div>
<div id="panel">
<div id="status">
<div class="top">Status</div>
<div class="mid">
<div id="server_state">
<?php include('status.php');?>
</div>
</div>
<div class="bot"></div>
</div>

<div id="navigation">
<?php 
if (file_exists('navigation.xml')){
	$XML = simplexml_load_file('navigation.xml');
	if ($XML === false) throw new Exception('Malformed XML');
}else{die('Unable to load navigation.xml');}
foreach ($XML->category as $cat){
	echo '<div class="top">'.$cat['name'].'</div><ul>'."\n";
	foreach ($cat->item as $item)
		echo '<li><a href="'.$item['href'].'">'.$item.'</a></li>'."\n";
	echo '</ul><div class="bot"></div>'."\n";
}
?>
</div>
<div id="friends">
<div class="top">Sponsor</div>
<div class="mid">
<script type="text/javascript"><!--
google_ad_client = "pub-5460616755902484";
/* 160x600, utworzono 08-08-14 */
google_ad_slot = "9645121234";
google_ad_width = 160;
google_ad_height = 600;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
<div class="bot"></div>
</div>
</div>