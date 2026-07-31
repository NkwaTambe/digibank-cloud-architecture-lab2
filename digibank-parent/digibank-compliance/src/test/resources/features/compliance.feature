Feature: Transaction amount validation

  Scenario: Amount as agreed
    Given a transaction amount of 5000
    When the compliance check is performed
    Then the transaction is accepted

  Scenario: Incorrect amount
    Given a transaction amount of 20000
    When the compliance check is performed
    Then the transaction is rejected
