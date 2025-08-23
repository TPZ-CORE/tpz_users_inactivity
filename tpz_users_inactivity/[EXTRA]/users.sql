
ALTER TABLE `users` 
ADD COLUMN `inactivity_time` INT(11) DEFAULT 0,
ADD COLUMN `notified_inactivity` INT(1) DEFAULT 0;