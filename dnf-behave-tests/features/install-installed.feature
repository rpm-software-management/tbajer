Feature: Install installed RPMs


Scenario: Install installed RPM when upgrade is available
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Install installed RPM when upgrade is available with option --nobest
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --nobest"
   Then the exit code is 0
    And Transaction is empty


Scenario: Install installed RPM when downgrade is available
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-26.fc29.x86_64               |
        | install       | glibc-common-0:2.28-26.fc29.x86_64        |
        | install       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is empty


Scenario: Install installed RPM by NEVR when upgrade is available
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc-0:2.28-9.fc29"
   Then the exit code is 0
    And Transaction is empty


Scenario: Install installed RPM by NEVR when downgrade is available
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-26.fc29.x86_64               |
        | install       | glibc-common-0:2.28-26.fc29.x86_64        |
        | install       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
   When I execute dnf with args "install glibc-0:2.28-26.fc29"
   Then the exit code is 0
    And Transaction is empty
