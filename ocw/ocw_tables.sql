-- MySQL dump 10.9
--
-- Host: localhost    Database: ocw
-- ------------------------------------------------------
-- Server version	4.1.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `content`
--

DROP TABLE IF EXISTS `content`;
CREATE TABLE `content` (
  `content_history_id` int(11) NOT NULL auto_increment,
  `content_id` int(11) NOT NULL default '0',
  `type` enum('Document','Audio','Video','Collection','Slide','Shockwave','URL','PDF','DownloadableFile') default 'Document',
  `title` varchar(255) NOT NULL default '',
  `body` text,
  `copyright` varchar(255) default NULL,
  `objectives` text,
  `authors` text,
  `course_id` int(10) unsigned NOT NULL default '0',
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`content_history_id`),
  KEY `content_i01` (`content_id`),
  KEY `content_i02` (`course_id`),
  KEY `c_state` (`state`),
  KEY `content_i03` (`content_id`,`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `course_history_id` int(11) NOT NULL auto_increment,
  `course_id` int(11) NOT NULL default '0',
  `school_id` int(10) unsigned NOT NULL default '0',
  `title` varchar(255) NOT NULL default '',
  `course_code` varchar(100) default NULL,
  `time_period` varchar(128) default NULL,
  `graphic_name` varchar(255) default NULL,
  `graphic_caption` text,
  `small_graphic` varchar(255) default NULL,
  `short_description` text,
  `course_length` varchar(20) default NULL,
  `level_label` varchar(255) default NULL,
  `description` text,
  `highlights` text,
  `additional_metadata` text,
  `objectives` text,
  `authors` text,
  `assistants` text,
  `subject` varchar(255),
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`course_history_id`),
  KEY `course_i01` (`course_id`),
  KEY `course_state` (`state`),
  KEY `c_school_id` (`school_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `course_category`
--

DROP TABLE IF EXISTS `course_category`;
CREATE TABLE `course_category` (
  `course_category_history_id` int(11) NOT NULL auto_increment,
  `course_category_token` varchar(50) NOT NULL default '',
  `category_name` varchar(255) default NULL,
  `course_id` int(11) NOT NULL default '0',
  `display_type` enum('Links','Document','Calendar') default 'Links',
  `sort_order` int(10) unsigned NOT NULL default '0',
  `description` text,
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`course_category_history_id`),
  KEY `course_category_i01` (`course_id`),
  KEY `course_category_i02` (`course_category_token`),
  KEY `cc_state` (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `course_session`
--

DROP TABLE IF EXISTS `course_session`;
CREATE TABLE `course_session` (
  `course_session_history_id` int(11) NOT NULL auto_increment,
  `course_session_id` int(11) NOT NULL default '0',
  `course_id` int(11) NOT NULL default '0',
  `type` enum('Lecture','Small Group','Conference','Laboratory','Examination','Divider', 'Seminar','Quiz','Workshop','Holiday') NOT NULL default 'Lecture',
  `title` varchar(255) default NULL,
  `sort_order` int(11) NOT NULL default '0',
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`course_session_history_id`),
  KEY `course_session_i01` (`course_session_id`),
  KEY `course_session_i02` (`course_id`),
  KEY `cs_state` (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `link_content_content`
--

DROP TABLE IF EXISTS `link_content_content`;
CREATE TABLE `link_content_content` (
  `link_content_content_id` int(11) NOT NULL auto_increment,
  `parent_content_id` int(11) NOT NULL default '0',
  `child_content_id` int(11) NOT NULL default '0',
  `course_id` int(10) unsigned NOT NULL default '0',
  `sort_order` int(11) NOT NULL default '0',
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`link_content_content_id`),
  KEY `link_content_content_i01` (`parent_content_id`),
  KEY `link_content_content_i02` (`child_content_id`),
  KEY `lcc_state` (`state`),
  KEY `lcc_course_id` (`course_id`),
  KEY `lcc_sort_order` (`sort_order`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `link_course_category_content`
--

DROP TABLE IF EXISTS `link_course_category_content`;
CREATE TABLE `link_course_category_content` (
  `link_course_category_content_id` int(11) NOT NULL auto_increment,
  `parent_course_category_token` varchar(50) NOT NULL default '',
  `child_content_id` int(11) NOT NULL default '0',
  `course_id` int(10) unsigned NOT NULL default '0',
  `course_session_id` int(11) NOT NULL default '0',
  `label` varchar(255) default NULL,
  `anchor_label` varchar(100) default NULL,
  `sort_order` int(11) NOT NULL default '0',
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`link_course_category_content_id`),
  KEY `link_course_category_content_i02` (`child_content_id`),
  KEY `link_course_category_content_i03` (`course_session_id`),
  KEY `link_course_category_content_i01` (`parent_course_category_token`),
  KEY `link_course_category_content_icourse_id` (`course_id`),
  KEY `lccc` (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `page_history_id` int(11) NOT NULL auto_increment,
  `token` varchar(50) NOT NULL default '',
  `title` varchar(255) NOT NULL default '',
  `body` text,
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`page_history_id`),
  KEY `page_i01` (`token`),
  KEY `p_state` (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `school`
--

DROP TABLE IF EXISTS `school`;
CREATE TABLE `school` (
  `school_history_id` int(11) NOT NULL auto_increment,
  `school_id` int(11) NOT NULL default '0',
  `school_label` varchar(255) default NULL,
  `school_image` varchar(255) default NULL,
  `school_desc` text,
  `sort_order` int(11) NOT NULL default '0',
  `state` enum('Hidden','Active','Archived','Error') NOT NULL default 'Hidden',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`school_history_id`),
  KEY `school_i01` (`school_id`),
  KEY `s_state` (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

