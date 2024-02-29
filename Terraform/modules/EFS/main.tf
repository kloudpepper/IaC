##################
### EFS Module ###
##################

resource "aws_efs_file_system" "EFSFileSystem" {
    creation_token                          = "EFSFileSystem"
    performance_mode                        = "generalPurpose"
    encrypted                               = true
    throughput_mode                         = "bursting"
    lifecycle_policy {
        transition_to_ia                    = "AFTER_30_DAYS"
        }
    lifecycle_policy {
        transition_to_primary_storage_class = "AFTER_1_ACCESS"
        }
    tags = {
        Name                                = "${var.environmentName}-EFS"
        }
}

resource "aws_efs_mount_target" "EFSMountTarget1" {
    file_system_id                          = aws_efs_file_system.EFSFileSystem.id
    security_groups                         = [var.EFSSecurityGroup_id]
    subnet_id                               = var.PrivateSubnet1_id
}

resource "aws_efs_mount_target" "EFSMountTarget2" {
    file_system_id                          = aws_efs_file_system.EFSFileSystem.id
    security_groups                         = [var.EFSSecurityGroup_id]
    subnet_id                               = var.PrivateSubnet2_id
}

resource "aws_efs_access_point" "import-request" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/opt/tocfee/request"
  }
  tags = {
        Name                                = "import-request"
    }
}

resource "aws_efs_access_point" "import-response" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/opt/tocfee/response"
  }
  tags = {
        Name                                = "import-response"
    }
}

resource "aws_efs_access_point" "import-error" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/opt/tocfee/error"
  }
  tags = {
        Name                                = "import-error"
    }
}

resource "aws_efs_access_point" "dw-export" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/s3"
  }
  tags = {
        Name                                = "dw-export"
    }
}

resource "aws_efs_access_point" "dfe" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/t24/DFE"
  }
  tags = {
        Name                                = "dfe"
    }
}

resource "aws_efs_access_point" "udexternal" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/t24/UDExternal"
  }
  tags = {
        Name                                = "udexternal"
    }
}

resource "aws_efs_access_point" "cfrextract" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/${var.environmentName}/CRF.EXTRACT"
  }
  tags = {
        Name                                = "cfrextract"
    }
}

resource "aws_efs_access_point" "TAFJ_log" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/t24/TAFJ_log"
  }
  tags = {
        Name                                = "TAFJ_log"
    }
}

resource "aws_efs_access_point" "TAFJ_logT24" {
  file_system_id                            = aws_efs_file_system.EFSFileSystem.id
  root_directory {
    creation_info {
      owner_gid                             = 1000
      owner_uid                             = 1000
      permissions                           = 777
    }
    path                                    = "/t24/TAFJ_logT24"
  }
  tags = {
        Name                                = "TAFJ_logT24"
    }
}