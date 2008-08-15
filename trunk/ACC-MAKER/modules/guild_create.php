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
//retrieve post data
$form = new Form('new_guild');
//check if any data was submited
if ($form->exists()){
	$form->attrs['guild_name'] = ucfirst($form->attrs['guild_name']);
	//check for correct guild name
	if (AAC::ValidGuildName($form->attrs['guild_name'])){
		$new_guild = new Guild();
		$new_guild->setAttr('name', $form->attrs['guild_name']);
		if (!$new_guild->exists()){
			$owner = new Player();
			//load owner character
			if ($owner->load($form->attrs['leader'])){
				//check if belong to current account
				if ($owner->getAttr('account') == $_SESSION['account']){
					//check if owner belongs to any guild
					if (!$owner->isAttr('guild_id')){
						if ($owner->getAttr('level') >= $cfg['guild_leader_level']){
							//create guild and add owner as a leader
							$new_guild->setAttr('owner_id', $owner->getAttr('id'));
							$new_guild->memberJoin($owner->getAttr('id'), 3, 'Leader');
							$new_guild->save();
							$account->logAction('Created guild: '.$new_guild->getAttr('name'));
							
							//success
							$msg = new IOBox('message');
							$msg->addMsg('Guild was created');
							$msg->addClose('Finish');
							$msg->show();
						}else $error = 'Character level too low';
					}else $error = 'This character already belongs to guild';
				}else $error = 'Not your character';
			}else $error = 'Cannot load player';
		}else $error = 'Guild exists with this name';
	}else $error = 'Not a valid name';
	if (!empty($error)){
		//create new message
		$msg = new IOBox('message');
		$msg->addMsg($error);
		$msg->addReload('<< Back');
		$msg->addClose('OK');
		$msg->show();
	}
}else{
	if (isset($account->players))
		foreach ($account->players as $player)
			$list[$player['id']] = $player['name'];
	//create new form
	$form = new IOBox('new_guild');
	$form->target = $_SERVER['PHP_SELF'];
	$form->addLabel('Create Guild');
	if (empty($list)){
		$form->addMsg('Your account does not have any characters.');
		$form->addClose('Close');
	}else{
		$form->addMsg('Select guild name and the owner. Must have at least level '.$cfg['guild_leader_level']);
		$form->addInput('guild name');
		$form->addSelect('leader',$list);
		$form->addClose('Cancel');
		$form->addSubmit('Next >>');
	}
	$form->show();
}
?>