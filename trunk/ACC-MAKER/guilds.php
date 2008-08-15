<?php 
/*
    Copyright (C) 2007 - 2008  Nicaw

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
include ("include.inc.php");
$ptitle="Guilds - $cfg[server_name]";
include ("header.inc.php");
$SQL = new SQL();
?>
<div id="content">
<div class="top">Guilds</div>
<div class="mid">
<form method="get" action="guilds.php"> 
<input type="text" name="guild_name"/> 
<input type="submit" value="Search"/> 
</form>
<hr style="margin-top: 5px; margin-bottom: 5px; "/>
<?php 
//-----------------------Guild list
if (!isset($_GET['guild_id']) && !isset($_GET['guild_name'])){
$query = 'SELECT guilds.id, guilds.name, nicaw_guild_info.description FROM guilds LEFT JOIN nicaw_guild_info ON guilds.id = nicaw_guild_info.id ORDER BY name ASC';
$SQL->myQuery($query);
if ($SQL->failed())
	throw new Exception('SQL query failed:<br/>'.$SQL->getError());
while ($a = $SQL->fetch_array()){
if (file_exists('guilds/'.$a['id'].'.gif')) 
	$img_path = 'guilds/'.$a['id'].'.gif';
else
	$img_path = 'ico/guild_default.gif';
?>
<table border="1" onclick="window.location.href='guilds.php?guild_id=<?php echo urlencode($a['id'])?>'" style="cursor: pointer; width: 100%;">
<tr><td style="width: 64px; height: 64px; padding: 10px;"><img src="<?php echo $img_path?>" alt="NO IMG" height="64" width="64"/></td>
<td style="vertical-align: top;">
<b><?php echo htmlspecialchars($a['name'])?></b><hr/>
<?php echo htmlspecialchars($a['description'])?>
</td></tr>
</table>
	
<?php }
}else{
//-------------------------Member list
$guild = new Guild();
if (!empty($_GET['guild_id']) && !$guild->load($_GET['guild_id']))
	echo 'Guild not found.';
elseif (!empty($_GET['guild_name']) && !$guild->find($_GET['guild_name']))
	echo 'Guild not found.';
else{
if (file_exists('guilds/'.$guild->getAttr('id').'.gif')) 
	$img_path = 'guilds/'.$guild->getAttr('id').'.gif';
else
	$img_path = 'ico/guild_default.gif';
?>
<table style="width: 100%"><tr><td style="width: 64px; height: 64px; padding: 10px;"><img src="<?php echo $img_path?>" alt="Guild IMG" height="64" width="64"/></td><td style="text-align: center">
<h1 style="display: inline"><?php echo htmlspecialchars($guild->getAttr('name'))?>
</h1></td><td style="width: 64px; height: 64px; padding: 10px;">
<img src="<?php echo $img_path?>" alt="Guild IMG" height="64" width="64"/></td></tr>
</table>
<p><?php echo htmlspecialchars($guild->getAttr('description'))?></p><hr/>
<ul class="task-menu" style="width: 200px;">
<li style="background-image: url(ico/book_previous.png);" onclick="self.window.location.href='guilds.php'">Back</li>
<?php 
if (!empty($_SESSION['account'])){
	$account = new Account();
	if (!$account->load($_SESSION['account'])) die('Cannot load account');
	$invited = false;
	$member = false;
	foreach ($account->players as $player){
		if ($guild->isInvited($player['id']))
			$invited = true;
		if ($guild->isMember($player['id']))
			$member = true;
	}
	if ($guild->getAttr('owner_acc') == $_SESSION['account']){?>
<li style="background-image: url(ico/user_go.png);" onclick="ajax('form','modules/guild_invite.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Invite Player</li>
<li style="background-image: url(ico/group_delete.png);" onclick="ajax('form','modules/guild_kick.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Kick Member</li>
<li style="background-image: url(ico/user_edit.png);" onclick="ajax('form','modules/guild_edit.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Edit Member</li>
<li style="background-image: url(ico/image_add.png);" onclick="ajax('form','modules/guild_image.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Upload Image</li>
<li style="background-image: url(ico/page_edit.png);" onclick="ajax('form','modules/guild_comments.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Edit Description</li>
<?php 	}
	if ($invited){?>
<li style="background-image: url(ico/user_red.png);" onclick="ajax('form','modules/guild_join.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Join Guild</li>
<?php 	}
	if ($member){?>
<li style="background-image: url(ico/user_delete.png);" onclick="ajax('form','modules/guild_leave.php','guild_id=<?php echo $guild->getAttr('id')?>',true)">Leave Guild</li>
<?php 	}?>
<li style="background-image: url(ico/resultset_previous.png);" onclick="self.window.location.href='login.php?logout&amp;redirect=account.php'">Logout</li>
<?php }else{?>
<li style="background-image: url(ico/resultset_next.png);" onclick="self.window.location.href='login.php?redirect=guilds.php'">Login</li>
<?php }?>
</ul><hr/>
<h2 style="display: inline">Guild Members</h2>
<table style="width: 100%">
<tr class="color0"><td style="width: 30%"><b>Rank</b></td><td style="width: 70%"><b>Name and Title</b></td></tr>
<?php 
foreach ($guild->members as $a)
	$members[$a['rank']][] = array('id' => $a['id'], 'name' => $a['name'], 'nick' => $a['nick']);
foreach ($guild->invited as $a)
	$members[$a['rank']][] = array('id' => $a['id'], 'name' => $a['name'], 'nick' => 'Invited');

$i = 0;
while ($rank = current($members)){
	$i++;
	$rank_name = key($members);
	foreach ($rank as $member){
		if (!empty($member['nick'])) $nick = ' (<i>'.htmlspecialchars($member['nick']).'</i>)';
		else $nick = '';
		echo '<tr '.getStyle($i).'><td>'.htmlspecialchars($rank_name).'</td><td><a href="characters.php?player_id='.$member['id'].'">'.htmlspecialchars($member['name']).'</a> '.$nick.'</td></tr>';
		$rank_name = '';
	}
	next($members);
}
?>
</table>
<?php }
}?>
</div>
<div class="bot"></div>
</div>
<?php include('footer.inc.php');?>