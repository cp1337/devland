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
if ($guild->getAttr('owner_acc') != $_SESSION['account']) die('Not your guild');
//retrieve post data
$fselect = new Form('edit_select');
$fedit = new Form('edit');
//check if any data was submited
if ($fselect->exists()){
	if ($guild->isMember($fselect->attrs['player'])){
	$player = new Player();
		if ($player->load($fselect->attrs['player'])){
			//create new form
			$form = new IOBox('edit');
			$form->target = $_SERVER['PHP_SELF'].'?guild_id='.$guild->getAttr('id').'&player_id='.$player->getAttr('id');
			$form->addLabel('Edit Member');
			$form->addMsg('Editing: '.$player->getAttr('name'));
			$form->addInput('rank', 'text', $player->getAttr('guild_rank'));
			$form->addInput('nick', 'text', $player->getAttr('guild_nick'));
			$form->addClose('Cancel');
			$form->addSubmit('Next >>');
			$form->show();
		}else $error = 'Cant load player';
	}else $error = 'Not a member of this guild';
	if (!empty($error)){
		//create new message
		$msg = new IOBox('message');
		$msg->addMsg($error);
		$msg->addClose('OK');
		$msg->show();
	}
}elseif ($fedit->exists()){
	if ($guild->isMember($_REQUEST['player_id'])){
	$fedit->attrs['rank'] = ucfirst($fedit->attrs['rank']);
	$fedit->attrs['nick'] = ucfirst($fedit->attrs['nick']);
		if (AAC::ValidGuildRank($fedit->attrs['rank']) && (AAC::ValidGuildNick($fedit->attrs['nick']) || empty($fedit->attrs['nick']))){
		$player = new Player();
			if ($player->load($_REQUEST['player_id'])){
				$guild->memberSetRank($player->getAttr('id'), $fedit->attrs['rank']);
				$guild->memberSetNick($player->getAttr('id'), $fedit->attrs['nick']);
				$guild->save();
				//success
				$msg = new IOBox('message');
				$msg->addMsg('Changes saved.');
				$msg->addRefresh('OK');
				$msg->show();
			}else $error = 'Cant load player';
		}else $error = 'Not a valid format for rank/title';
	}else $error = 'Not a member of this guild';
	if (!empty($error)){
		//create new message
		$msg = new IOBox('message');
		$msg->addMsg($error);
		$msg->addClose('OK');
		$msg->show();
	}
}else{
	//make a list of member characters
	foreach ($guild->members as $member)
		$list[$member['id']] = $member['name'];
	if (!isset($list)) die();

	//create new form
	$form = new IOBox('edit_select');
	$form->target = $_SERVER['PHP_SELF'].'?guild_id='.$guild->getAttr('id');
	$form->addLabel('Edit Member');
	$form->addMsg('Select the character to edit.');
	$form->addSelect('player', $list);
	$form->addClose('Cancel');
	$form->addSubmit('Next >>');
	$form->show();
}
?>