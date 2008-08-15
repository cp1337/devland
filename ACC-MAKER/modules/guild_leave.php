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
include ("../include.inc.php");
//load account if loged in
$account = new Account();
($account->load($_SESSION['account'])) or die('You need to login first. '.$account->getError());
//load guild
$guild = new Guild();
if (!$guild->load($_REQUEST['guild_id'])) throw new Exception('Unable to load guild.');
//retrieve post data
$form = new Form('leave');
//check if any data was submited
if ($form->exists()){
	$player = new Player();
	if ($player->load($form->attrs['player']) && $player->getAttr('account') == $_SESSION['account']){
		if ($player->getAttr('id') == $guild->getAttr('owner_id')){
			$guild->remove();
			
			$msg = new IOBox('message');
			$msg->addMsg('Your guild was deleted');
			$msg->target = 'guilds.php';
			$msg->addClose('OK');
			$msg->show();
		}elseif ($guild->memberLeave($player->getAttr('id'))){
			$guild->save();
			//success
			$msg = new IOBox('message');
			$msg->addMsg('You have left '.htmlspecialchars($guild->getAttr('name')));
			$msg->addRefresh('OK');
			$msg->show();
		}else $error = 'Cannot leave guild';
	}else $error = 'Player cannot be loaded';
	if (!empty($error)){
		//create new message
		$msg = new IOBox('message');
		$msg->addMsg($error);
		$msg->addClose('OK');
		$msg->show();
	}
}else{
	//make a list of member characters
	foreach ($account->players as $player)
		if ($guild->isMember($player['id']))
			$list[$player['id']] = $player['name'];
	if (!isset($list)) die();

	//create new form
	$form = new IOBox('leave');
	$form->target = $_SERVER['PHP_SELF'].'?guild_id='.urlencode($_REQUEST['guild_id']);
	$form->addLabel('Leave Guild');
	if ($account->getAttr('accno') == $guild->getAttr('owner_acc'))
		$form->addMsg('If you leave with owner character guild will get disbanded!');
	$form->addMsg('Select the character to leave.');
	$form->addSelect('player', $list);
	$form->addClose('Cancel');
	$form->addSubmit('Continue >>');
	$form->show();
}
?>