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
$ptitle="Characters - $cfg[server_name]";
include("header.inc.php");
?>
<div id="content">
<div class="top">Character Lookup</div>
<div class="mid">
<form method="get" action="characters.php"> 
<input type="text" name="player_name"/> 
<input type="submit" value="Search"/> 
</form>
<?php 
$player = new Player();
if (!empty($_GET['player_id']) && $player->load($_GET['player_id']) || !empty($_GET['player_name']) && $player->find($_GET['player_name'])){
	echo '<hr/><table style="width: 100%"><tr><td><b>Name:</b> '.htmlspecialchars($player->getAttr('name'))."<br/>\n";
	echo '<b>Level:</b> '.$player->getAttr('level')."<br/>\n";
	echo '<b>Magic Level:</b> '.$player->getAttr('maglevel')."<br/>\n";
	echo '<b>Vocation:</b> '.$cfg['vocations'][$player->getAttr('vocation')]['name']."<br/>\n";

	if ($player->isAttr('guild_name')){
		echo '<b>Guild:</b> '.$player->getAttr('guild_rank').' of <a href="guilds.php?guild_id='.$player->getAttr('guild_id').'">'.htmlspecialchars($player->getAttr('guild_name')).'</a><br/>'."\n";
	}
	
	$gender = Array('Female','Male');
	echo '<b>Gender:</b> '.$gender[$player->getAttr('sex')].'<br/>'."\n";
	if (!empty($cfg['temple'][$player->getAttr('city')]['name']))
		echo "<b>Residence</b>: ".ucfirst($cfg['temple'][$player->getAttr('city')]['name'])."<br/>";

	if ($player->isAttr('position')){
		echo "<b>Position: </b> ".$player->getAttr('position')."<br/>";
	}
	if ($player->getAttr('premend') > 0){
		echo "<b>Premium: </b> ".ceil((time() - $player->getAttr('premend'))/(3600*24))." day(s)";
	}
	if ($player->getAttr('lastlogin') == 0)
		$lastlogin = 'Never';
	else
		$lastlogin = date("jS F Y H:i:s",$player->getAttr('lastlogin'));
	echo "<b>Last Login:</b> ".$lastlogin."<br/>\n";
	if ($player->getAttr('redskulltime') > time()) echo '<b>Frag time left:</b> '.ceil(($player->getAttr('redskulltime') - time())/60/60).' h</b><br/>';
	if ($cfg['show_skills']){
		echo "</td><td>";
		$sn = $cfg['skill_names'];
		for ($i=0; $i < count($sn); $i++){
			echo '<b>'.ucfirst($sn[$i]).':</b> '.$player->getSkill($i)."<br/>\n";
		}
		echo '</td></tr>';
	}
	echo '</table>';
	$account = new Account();
	if ($account->load($player->getAttr('account')))
		if (strlen($account->getAttr('comment'))>0){
			echo "<b>Comments</b><br/><div style=\"overflow:hidden\"><pre>".htmlspecialchars($account->getAttr('comment'))."</pre></div><br/>\n";
		}	
	echo '<hr/>';
	if ($cfg['show_deathlist']){
		$deaths = $player->getDeaths();
		if ($deaths !== false && !empty($deaths)){
		echo '<b>Deaths</b><br/>';
			foreach ($deaths as $death){
				$killer = new Player($death['killer']);
				if ($killer->exists())
					$name = '<a href="characters.php?char='.$death['killer'].'">'.$death['killer'].'</a>';
				else
					$name = $death['killer'];
				echo '<i>'.date("jS F Y H:i:s",$death['date']).'</i> Killed at level '.$death['level'].' by '.$name.'<br/>';
			}
		}
	}
}elseif (isset($_GET['player_id']) || isset($_GET['player_name'])) echo 'Player not found';
?>
</div>
<div class="bot"></div>
</div>
<?php include ("footer.inc.php");?>