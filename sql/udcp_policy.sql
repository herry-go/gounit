/*
		sql导出
	   
		数据库地址        : 10.20.22.113:10002
		数据库类型        : MySQL
		数据库名         : udcp_policy
	   
		生成时间: 2023-04-06 09:53:16
*/

DROP DATABASE IF EXISTS `udcp_policy_test`;
CREATE DATABASE `udcp_policy_test`;

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;
USE `udcp_policy_test`;


-- ----------------------------
-- Table structure for udcp_baseline
-- ----------------------------
DROP TABLE IF EXISTS `udcp_baseline`;
CREATE TABLE `udcp_baseline` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `pg_id` int(11) DEFAULT NULL COMMENT '策略表主键id',
  `policy_id` int(11) DEFAULT NULL COMMENT '策略明细表id',
  `baseline_dic_id` int(11) DEFAULT NULL COMMENT '基线维护项字典表',
  `department_id` int(11) DEFAULT NULL COMMENT '部门id',
  `version_symbol` tinyint(4) DEFAULT NULL COMMENT '基线版本符号(1大于等于、2等于、3小于等于)',
  `version_require` varchar(255) DEFAULT NULL COMMENT '基线版本要求',
  `package_name` varchar(255) DEFAULT NULL,
  `repair_config` mediumtext DEFAULT NULL,
  `os_arch` varchar(255) DEFAULT NULL COMMENT '系统架构（多选，枚举值：amd/arm，多个存储用逗号分隔开：amd,arm）',
  `is_compliance_check` tinyint(1) DEFAULT NULL COMMENT '是否为合规性检查',
  `risk_level` tinyint(4) DEFAULT NULL COMMENT '1不合格、2有风险、3待优化',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态 0正常 1异常',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;



-- ----------------------------
-- Table structure for udcp_cascade_policies
-- ----------------------------
DROP TABLE IF EXISTS `udcp_cascade_policies`;
CREATE TABLE `udcp_cascade_policies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `latest_uuid` varchar(32) NOT NULL DEFAULT '' COMMENT '关联级联任务表UUID',
  `unique_id` varchar(289) NOT NULL DEFAULT '' COMMENT '唯一标识ID,格式:策略组编号-源端节点企业代码-目的端节点企业代码',
  `policy_group_id` int(11) NOT NULL DEFAULT 0 COMMENT '策略组ID',
  `policy_group_number` varchar(255) NOT NULL DEFAULT '' COMMENT '策略组编号',
  `count_adjust_order` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '调整优先级的次数',
  `force_publish` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '是否是强制性发布的策略，默认0标识非强制；1标识强制。',
  `latest_policy_order` decimal(27,6) NOT NULL DEFAULT 0.000000 COMMENT '最新调整后的策略优先级。值越大，代表优先级越高。',
  `node_path` varchar(512) NOT NULL DEFAULT '' COMMENT '从源端到目的端节点路径，路径用企业代码加上符号>连接。',
  `self_node_code` varchar(16) NOT NULL DEFAULT '' COMMENT '自身的企业代号',
  `dest_node_level` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '目的节点在当前nodepath中的层级，即将nodepath分离后计算node的个数得到。',
  `src_node_code` varchar(16) NOT NULL DEFAULT '' COMMENT '发起本级联策略的源端节点企业代号',
  `src_node_name` varchar(100) NOT NULL DEFAULT '' COMMENT '发起本级联策略的源端节点企业名称',
  `dest_node_code` varchar(16) NOT NULL DEFAULT '' COMMENT '收到本级联策略的目的端节点企业代号',
  `dest_node_name` varchar(100) NOT NULL DEFAULT '' COMMENT '收到本级联策略的目的端节点企业名称',
  `latest_biz_status` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '最近的业务执行状态。',
  `dispatch_at` datetime DEFAULT NULL COMMENT '发起者派发这条策略组的时刻。',
  `latest_biz_status_at` datetime DEFAULT NULL COMMENT '业务最近执行状态时刻。',
  `created_at` datetime DEFAULT NULL COMMENT '创建时刻',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时刻',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时刻。',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `udcp_cascade_policies_a_index` (`unique_id`),
  KEY `udcp_cascade_policies_order_index` (`latest_policy_order`),
  KEY `udcp_cascade_policies_latestuuid_idx` (`latest_uuid`),
  KEY `udcp_cascade_policies_sc_cao_idx` (`dest_node_code`,`count_adjust_order`),
  KEY `udcp_caspg_srccode_idx` (`src_node_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='最近一次的级联策略概览数据表';



-- ----------------------------
-- Table structure for udcp_pg_audit
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_audit`;
CREATE TABLE `udcp_pg_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `pg_id` int(11) NOT NULL COMMENT '策略表主键id',
  `policy_id` int(11) NOT NULL COMMENT '策略明细表id',
  `type` tinyint(4) NOT NULL COMMENT '类型 1:文件审计 2:命令审计 3:进程审计 4:网络审计',
  `content` text NOT NULL COMMENT '审计内容',
  `options` varchar(255) NOT NULL COMMENT '审计选项',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='审计策略表';



-- ----------------------------
-- Table structure for udcp_pg_change_log
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_change_log`;
CREATE TABLE `udcp_pg_change_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `types` varchar(32) NOT NULL DEFAULT '' COMMENT '变更内容，变更多种类型用逗号分隔，100-基本属性，200-执行范围，300-计算机配置，400-用户配置',
  `pg_id` int(11) NOT NULL DEFAULT 0 COMMENT '策略组id',
  `pg_name` varchar(255) NOT NULL DEFAULT '' COMMENT ' 策略组名称（避免关联查询）',
  `data` text DEFAULT NULL COMMENT '日志数据（具体操作的数据，根据实际业务情况填写，前端不用展示）',
  `create_uid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '创建人id',
  `create_name` varchar(255) NOT NULL DEFAULT '' COMMENT '创建人名称',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `index_pg_id` (`pg_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='策略变更日志表';



-- ----------------------------
-- Table structure for udcp_pg_config
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_config`;
CREATE TABLE `udcp_pg_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `policy_id` int(10) unsigned NOT NULL COMMENT '策略明细表主键id',
  `config_key` varchar(255) NOT NULL COMMENT '配置项键,必须唯一',
  `config_value` longtext NOT NULL COMMENT '配置项值',
  `config_group_id` int(11) NOT NULL COMMENT '配置分组id',
  PRIMARY KEY (`id`),
  KEY `index_policy_id` (`policy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=353 DEFAULT CHARSET=utf8 COMMENT='策略配置明细表';



-- ----------------------------
-- Table structure for udcp_pg_config_dic
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_config_dic`;
CREATE TABLE `udcp_pg_config_dic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `policy_key` varchar(255) NOT NULL COMMENT '所属策略key类型',
  `config_key` varchar(255) NOT NULL COMMENT '配置key类型,必须唯一',
  `config_vals` text DEFAULT NULL COMMENT '配置值列表(如果为空则表示非列表值)',
  `config_default_val` text DEFAULT NULL COMMENT '配置默认值',
  `order_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '排序号',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `childs_config_keys` varchar(4096) DEFAULT NULL COMMENT 'config下存在子配置',
  `type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '策略编辑类型  0单选  1checkbox   2 图片  3 脚本  4 输入   5应用  6 快捷方式  7黑名单应用  8文件重定向',
  `config_cn` varchar(255) DEFAULT '' COMMENT '配置名称',
  `config_group_dic_id` int(11) NOT NULL COMMENT '配置分组id',
  `compatible` tinyint(4) DEFAULT NULL COMMENT '是否兼容',
  `link_key` varchar(255) DEFAULT NULL COMMENT '兼容的老版本的key值',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_config_key` (`config_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=utf8 COMMENT='配置字典表';



-- ----------------------------
-- Table structure for udcp_pg_config_group_dic
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_config_group_dic`;
CREATE TABLE `udcp_pg_config_group_dic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_group_name` varchar(255) NOT NULL COMMENT '配置分组名称',
  `policy_dic_id` int(11) NOT NULL COMMENT '配置项字典表id',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `order_id` int(11) NOT NULL COMMENT '排序号',
  `disable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否停用（是：1 否：0，默认停用）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8;



-- ----------------------------
-- Table structure for udcp_pg_dic
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_dic`;
CREATE TABLE `udcp_pg_dic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `policy_category` tinyint(3) unsigned DEFAULT NULL COMMENT '策略类型（枚举值：计算机配置 100 / 用户配置 200）',
  `policy_second_category` tinyint(3) unsigned DEFAULT NULL COMMENT '策略二级类型（枚举值：计算机配置-基础配置 101 / 计算机配置-高级配置 102 / 计算机配置-安全管理 103 / 计算机配置-应用管理 104 / 用户配置-基础配置 201）',
  `policy_name` varchar(255) NOT NULL COMMENT '策略名称，必须唯一',
  `policy_key` varchar(255) NOT NULL COMMENT '策略key(值唯一，不能重复)',
  `disable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '策略是否启用（是：1 否：0，默认停用）',
  `lock` tinyint(4) DEFAULT 0 COMMENT '策略是否锁定（是：1 否：0，默认不锁定）',
  `compose` tinyint(4) NOT NULL DEFAULT 0 COMMENT '策略是否可以累加（是：1 否：0，默认不累加,只有下发脚本）',
  `order_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '排序号',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `policy_level` varchar(10) NOT NULL DEFAULT '' COMMENT '策略级别，枚举值，system-system级，登录前执行，session-session级，登录后执行',
  `is_pc` tinyint(4) DEFAULT NULL COMMENT '是否终端策略',
  `is_user` tinyint(4) DEFAULT NULL COMMENT '是否用户策略',
  `icon` varchar(255) DEFAULT NULL COMMENT 'icon图片路径',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_policy_key` (`policy_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8 COMMENT='策略字典表';



-- ----------------------------
-- Table structure for udcp_pg_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_operation_log`;
CREATE TABLE `udcp_pg_operation_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` tinyint(4) NOT NULL COMMENT '操作类型，1-新增发布，2-编辑策略组，3-删除策略组，4-批量删除策略组，5-停用策略组，6-启用策略组，7-策略组详情查看，8-部门关联策略查看，9-策略预览，10-优先级降低，11-优先级提升，12-导出策略组',
  `department_id` int(11) DEFAULT 0 COMMENT '操作对象（部门id）',
  `department_name` varchar(255) DEFAULT '' COMMENT '操作对象（部门名称，避免关联查询）',
  `pg_id` varchar(255) DEFAULT '0' COMMENT '操作对象（策略组id，可能包含多个，多个用逗号分割：批量删除，批量启用）',
  `pg_name` varchar(255) DEFAULT '' COMMENT '操作对象（策略组名称，避免关联查询）',
  `data` text DEFAULT NULL COMMENT '日志数据（具体操作的数据，根据实际业务情况填写，前端不用展示）',
  `create_uid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '创建人id',
  `create_name` varchar(255) NOT NULL DEFAULT '' COMMENT '创建人名称',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `index_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='策略管理日志表';



-- ----------------------------
-- Table structure for udcp_pg_pc_group
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_pc_group`;
CREATE TABLE `udcp_pg_pc_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pg_id` int(10) unsigned NOT NULL COMMENT '策略组表主键id',
  `pc_group_id` int(10) NOT NULL COMMENT '部分生效/部分例外关联的终端组id',
  `pc_group_name` varchar(255) DEFAULT '' COMMENT '终端组名称 ',
  PRIMARY KEY (`id`),
  KEY `index_pg_id` (`pg_id`),
  KEY `index_pc_group_id` (`pc_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='策略终端组关联表';



-- ----------------------------
-- Table structure for udcp_pg_policy
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_policy`;
CREATE TABLE `udcp_pg_policy` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pg_id` int(10) unsigned NOT NULL COMMENT '策略组表主键id',
  `policy_key` varchar(255) NOT NULL COMMENT '策略名称，必须唯一',
  `disable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否停用，0-否，1-是，默认0',
  `lock` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否锁定，0-否，1-是，默认0',
  `pg_tmpl_id` int(11) DEFAULT 0 COMMENT '策略模板表主键id',
  PRIMARY KEY (`id`),
  KEY `index_pg_id` (`pg_id`),
  KEY `index_pg_tmpl_id` (`pg_tmpl_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8 COMMENT='策略明细表';



-- ----------------------------
-- Table structure for udcp_pg_scope
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_scope`;
CREATE TABLE `udcp_pg_scope` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `department_id` int(11) DEFAULT NULL COMMENT '部门id',
  `pg_id` int(11) NOT NULL COMMENT '策略表主键id',
  `scope_decimal` bigint(20) DEFAULT NULL COMMENT '策略执行范围值(10进制)',
  `scope_binary` varchar(255) DEFAULT NULL COMMENT '策略执行范围值(2进制)',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `scope_id` int(11) DEFAULT NULL COMMENT '范围id',
  `scope_type` tinyint(4) DEFAULT NULL COMMENT '1部门 2终端组 3用户组 4级联节点 5终端id 6用户id',
  `is_exclude` tinyint(4) DEFAULT NULL COMMENT '0否（生效范围） 1是（例外范围）',
  `scope_name` varchar(255) DEFAULT NULL COMMENT '范围名称',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_department_id` (`department_id`) USING BTREE,
  KEY `index_pg_id` (`pg_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='策略范围表';



-- ----------------------------
-- Table structure for udcp_pg_sync
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_sync`;
CREATE TABLE `udcp_pg_sync` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pg_pull_cycle` int(10) NOT NULL COMMENT '拉取策略的同步周期时间，单位分钟',
  `pg_pull_random` int(10) NOT NULL COMMENT '拉取策略的同步随机数，单位分钟',
  `pg_exec_cycle` int(10) NOT NULL COMMENT '策略执行周期，单位分钟',
  `pg_sync_task_exec_cycle` int(10) NOT NULL COMMENT '策略同步任务执行周期，单位分钟',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='策略同步设置表';



-- ----------------------------
-- Table structure for udcp_pg_sys_config
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_sys_config`;
CREATE TABLE `udcp_pg_sys_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sys_key` varchar(255) DEFAULT NULL COMMENT '配置键名称',
  `sys_value` text DEFAULT NULL COMMENT '配置值',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- ----------------------------
-- Table structure for udcp_pg_template
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_template`;
CREATE TABLE `udcp_pg_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL COMMENT '策略模板名称',
  `description` varchar(255) DEFAULT NULL COMMENT '详细信息',
  `create_uid` int(11) DEFAULT NULL COMMENT '创建人',
  `create_name` varchar(255) DEFAULT NULL COMMENT '创建人名称',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '修改时间',
  `pg_type` tinyint(4) NOT NULL COMMENT '策略类型（0 计算机策略 1 用户策略）',
  `tmpl_type` tinyint(4) NOT NULL COMMENT '模板类型 （1 策略组模板  2 防火墙模板  3 网络探针模板）',
  `tmpl_value` text DEFAULT NULL COMMENT '模板内容',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;



-- ----------------------------
-- Table structure for udcp_pg_user_group
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_user_group`;
CREATE TABLE `udcp_pg_user_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pg_id` int(10) unsigned NOT NULL COMMENT '策略组表主键id',
  `user_group_id` int(10) NOT NULL COMMENT '部分生效/部分例外关联的用户组id',
  `user_group_name` varchar(255) DEFAULT '' COMMENT '用户组名称 ',
  PRIMARY KEY (`id`),
  KEY `index_pg_id` (`pg_id`),
  KEY `index_user_group_id` (`user_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='策略用户组关联表';



-- ----------------------------
-- Table structure for udcp_pg_user_role
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_user_role`;
CREATE TABLE `udcp_pg_user_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `pg_id` int(11) NOT NULL COMMENT '策略表主键id',
  `user_role_id` int(11) NOT NULL COMMENT '用户角色id',
  `user_role_name` varchar(255) NOT NULL COMMENT '用户角色名称',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_pg_id` (`pg_id`) USING BTREE,
  KEY `index_user_role_id` (`user_role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='策略用户角色表';



-- ----------------------------
-- Table structure for udcp_pg_version
-- ----------------------------
DROP TABLE IF EXISTS `udcp_pg_version`;
CREATE TABLE `udcp_pg_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `calc_version` varchar(255) DEFAULT NULL COMMENT '计算版本号',
  `exec_version` varchar(255) DEFAULT NULL COMMENT '执行版本号',
  `machine_id` varchar(255) DEFAULT NULL COMMENT '终端机器id',
  `user_id` int(11) DEFAULT NULL COMMENT '用户id',
  `md5` varchar(255) DEFAULT NULL COMMENT '策略计算结果md5值',
  `pg_numbers` text DEFAULT NULL COMMENT '关联策略编号',
  `status` int(11) DEFAULT NULL COMMENT '状态（0异常，1正常）',
  `has_baseline_check` tinyint(1) DEFAULT NULL COMMENT '是否有基线检查(0没有， 1 有)',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `machine_id_index` (`machine_id`) USING BTREE,
  KEY `user_id_index` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;



-- ----------------------------
-- Table structure for udcp_policy_calc_task
-- ----------------------------
DROP TABLE IF EXISTS `udcp_policy_calc_task`;
CREATE TABLE `udcp_policy_calc_task` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `task_type` varchar(255) NOT NULL COMMENT '策略计算类型',
  `task_data` text NOT NULL COMMENT '任务内容',
  `finish` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否完成，0-否，1-是，默认0',
  `retry_count` tinyint(4) NOT NULL DEFAULT 0 COMMENT '重试次数',
  `retry_reason` text DEFAULT NULL COMMENT '重试原因',
  `create_uid` int(10) unsigned NOT NULL COMMENT '创建人id',
  `create_name` varchar(255) NOT NULL COMMENT '创建人',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8 COMMENT='策略计算任务表';



-- ----------------------------
-- Table structure for udcp_policy_config_dic
-- ----------------------------
DROP TABLE IF EXISTS `udcp_policy_config_dic`;
CREATE TABLE `udcp_policy_config_dic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `policy_key` varchar(255) NOT NULL COMMENT '所属策略key类型',
  `config_key` varchar(255) NOT NULL COMMENT '配置key类型,必须唯一',
  `config_vals` text DEFAULT NULL COMMENT '配置值列表(如果为空则表示非列表值)',
  `config_default_val` text DEFAULT NULL COMMENT '配置默认值',
  `order_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '排序号',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `childs_config_keys` varchar(4096) DEFAULT NULL COMMENT 'config下存在子配置',
  `type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '策略编辑类型  0单选  1checkbox   2 图片  3 脚本  4 输入   5应用  6 快捷方式  7黑名单应用  8文件重定向',
  `config_cn` varchar(255) DEFAULT '' COMMENT '配置名称',
  `config_group_dic_id` int(11) NOT NULL COMMENT '配置分组id',
  `compatible` tinyint(4) DEFAULT NULL COMMENT '是否兼容',
  `link_key` varchar(255) DEFAULT NULL COMMENT '兼容的老版本的key值',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_config_key` (`config_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=230 DEFAULT CHARSET=utf8 COMMENT='配置字典表';



-- ----------------------------
-- Table structure for udcp_policy_config_group_dic
-- ----------------------------
DROP TABLE IF EXISTS `udcp_policy_config_group_dic`;
CREATE TABLE `udcp_policy_config_group_dic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_group_name` varchar(255) NOT NULL COMMENT '配置分组名称',
  `policy_dic_id` int(11) NOT NULL COMMENT '配置项字典表id',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `order_id` int(11) NOT NULL COMMENT '排序号',
  `disable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否停用（是：1 否：0，默认停用）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;



-- ----------------------------
-- Table structure for udcp_policy_dic
-- ----------------------------
DROP TABLE IF EXISTS `udcp_policy_dic`;
CREATE TABLE `udcp_policy_dic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `policy_category` tinyint(3) unsigned DEFAULT NULL COMMENT '策略类型（枚举值：计算机配置 100 / 用户配置 200）',
  `policy_second_category` tinyint(3) unsigned DEFAULT NULL COMMENT '策略二级类型（枚举值：计算机配置-基础配置 101 / 计算机配置-高级配置 102 / 计算机配置-安全管理 103 / 计算机配置-应用管理 104 / 用户配置-基础配置 201）',
  `policy_name` varchar(255) NOT NULL COMMENT '策略名称，必须唯一',
  `policy_key` varchar(255) NOT NULL COMMENT '策略key(值唯一，不能重复)',
  `disable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '策略是否启用（是：1 否：0，默认停用）',
  `lock` tinyint(4) DEFAULT 0 COMMENT '策略是否锁定（是：1 否：0，默认不锁定）',
  `compose` tinyint(4) NOT NULL DEFAULT 0 COMMENT '策略是否可以累加（是：1 否：0，默认不累加,只有下发脚本）',
  `order_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '排序号',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `policy_level` varchar(10) NOT NULL DEFAULT '' COMMENT '策略级别，枚举值，system-system级，登录前执行，session-session级，登录后执行',
  `is_pc` tinyint(4) DEFAULT NULL COMMENT '是否终端策略',
  `is_user` tinyint(4) DEFAULT NULL COMMENT '是否用户策略',
  `icon` varchar(255) DEFAULT NULL COMMENT 'icon图片路径',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_policy_key` (`policy_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8 COMMENT='策略字典表';

