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

class AAC
{
	public function ValidPlayerName($name)
	{global $cfg;
		foreach ($cfg['invalid_names'] as $baned_name)
			if (eregi($baned_name,$name))
				return false;
		return preg_match("/^[A-Z][a-z]{1,20}([ '-][A-Za-z][a-z]{1,15}){0,3}$/",$name)
		&& strlen($name) <= 25 && strlen($name) >= 4
		&& !file_exists($cfg['dirdata'].'monster/'.$name.'.xml')
		&& !file_exists($cfg['dirdata'].'npc/'.$name.'.xml');
	}
	
	public function ValidPassword($pass)
	{
		return strlen($pass) > 5;
	}
	
	public function ValidAccountNumber($n)
	{
		return is_numeric($n) && $n > 100000 && $n < 100000000;
	}
	
	public function ValidEmail($email)
	{
		return eregi('^[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}$',$email);
	}
	
	public function ValidGuildName($name)
	{
		return preg_match("/^[A-Z][a-z]{1,20}([ '-][A-Za-z][a-z]{1,15}){0,3}$/",$name);
	}
	
	public function ValidGuildRank($name)
	{
		return preg_match("/^[A-Z][a-z]{1,20}([ '-][A-Za-z][a-z]{1,15}){0,3}$/",$name);
	}
	
	public function ValidGuildNick($name)
	{
		return preg_match("/^[A-Z][a-z]{1,20}([ '-][A-Za-z][a-z]{1,15}){0,3}$/",$name);
	}
	
	public function getExperienceByLevel($lvl)
	{
		return floor(50*($lvl-1)*($lvl*$lvl-5*$lvl+12)/3);
	}
}

function exception_handler($exception) {
	echo '<pre style="position: absolute; top: 0px; left: 0px; background-color: white; color: black; border: 3px solid red;"><b>'.$exception->getMessage(). '<br/>'.basename($exception->getFile()).' on line: '.$exception->getLine().'</b><br/>Script was terminated because something unexpected happened. You can report this, if you think it\'s a bug.';
}

function strToDate($str){
  $pieces = explode('-',$str);
  return mktime(0,0,0,(int)$pieces[1],(int)$pieces[2],(int)$pieces[0]);
}

function getVocLvl($voc){
	global $cfg;
	return floor($cfg['vocations'][$voc]['level']);
}

function getVocExp($voc){
	global $cfg;
	$x = $cfg['vocations'][$voc]['level'];
	return round(50*($x-1)*(pow($x,2)-5*$x+12)/3);
}

function getStyle($seed)
{
	if ($seed % 2 == 0)
		return 'class="color1"';
	else
		return 'class="color2"';
}

function percent_bar($part, $total)
{
	if ($total <= 0) return 'unknown';
	$percent = round($part/$total*100);
	if ($percent >= 10)
		$percent_text = $percent.'%';
	return '<div class="percent_bar" style="width:'.($percent*2).'px">'.$percent_text.'</div>';
}

function deeper_array_search($needle, $haystack, $attribute)
{
	while ($v = current($haystack)){
		if ($v[$attribute] == $needle)
			return key($haystack);
		next($haystack);
	}
	return false;
}
?>