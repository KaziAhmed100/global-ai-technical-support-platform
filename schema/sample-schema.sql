/* Generic schema for AI Technical Support Platform (sanitized) */

CREATE TABLE Roles (
  RoleId INT IDENTITY PRIMARY KEY,
  RoleName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Users (
  UserId INT IDENTITY PRIMARY KEY,
  DisplayName NVARCHAR(200) NOT NULL,
  Email NVARCHAR(255) NULL,
  RoleId INT NOT NULL,
  IsActive BIT NOT NULL DEFAULT 1,
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);

CREATE TABLE KnowledgeArticles (
  ArticleId INT IDENTITY PRIMARY KEY,
  Title NVARCHAR(255) NOT NULL,
  Status NVARCHAR(50) NOT NULL DEFAULT 'Draft',  -- Draft/Approved/Archived
  ScopeTag NVARCHAR(100) NULL,                   -- e.g., "finance", "registrar"
  CurrentVersionId INT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE KnowledgeArticleVersions (
  VersionId INT IDENTITY PRIMARY KEY,
  ArticleId INT NOT NULL,
  VersionNumber INT NOT NULL,
  Body NVARCHAR(MAX) NOT NULL,
  CreatedByUserId INT NOT NULL,
  ApprovedByUserId INT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  ApprovedAt DATETIME2 NULL,
  FOREIGN KEY (ArticleId) REFERENCES KnowledgeArticles(ArticleId),
  FOREIGN KEY (CreatedByUserId) REFERENCES Users(UserId),
  FOREIGN KEY (ApprovedByUserId) REFERENCES Users(UserId)
);

CREATE TABLE Conversations (
  ConversationId INT IDENTITY PRIMARY KEY,
  UserId INT NOT NULL,
  Status NVARCHAR(50) NOT NULL DEFAULT 'Open',
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE Messages (
  MessageId INT IDENTITY PRIMARY KEY,
  ConversationId INT NOT NULL,
  SenderType NVARCHAR(20) NOT NULL,        -- user/assistant/system
  RedactedContent NVARCHAR(MAX) NOT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId)
);

CREATE TABLE Citations (
  CitationId INT IDENTITY PRIMARY KEY,
  MessageId INT NOT NULL,
  ArticleId INT NOT NULL,
  VersionId INT NULL,
  SnippetRef NVARCHAR(200) NULL,
  FOREIGN KEY (MessageId) REFERENCES Messages(MessageId),
  FOREIGN KEY (ArticleId) REFERENCES KnowledgeArticles(ArticleId),
  FOREIGN KEY (VersionId) REFERENCES KnowledgeArticleVersions(VersionId)
);

CREATE TABLE Tickets (
  TicketId INT IDENTITY PRIMARY KEY,
  CreatedByUserId INT NOT NULL,
  AssignedToUserId INT NULL,
  Category NVARCHAR(100) NULL,
  Priority NVARCHAR(50) NULL,
  Status NVARCHAR(50) NOT NULL DEFAULT 'Open',
  LinkedConversationId INT NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  FOREIGN KEY (CreatedByUserId) REFERENCES Users(UserId),
  FOREIGN KEY (AssignedToUserId) REFERENCES Users(UserId),
  FOREIGN KEY (LinkedConversationId) REFERENCES Conversations(ConversationId)
);

CREATE TABLE WorkflowDefinitions (
  WorkflowId INT IDENTITY PRIMARY KEY,
  WorkflowName NVARCHAR(200) NOT NULL,
  RequiredPermission NVARCHAR(200) NULL,
  StepsJson NVARCHAR(MAX) NOT NULL
);

CREATE TABLE WorkflowRuns (
  RunId INT IDENTITY PRIMARY KEY,
  WorkflowId INT NOT NULL,
  StartedByUserId INT NOT NULL,
  Status NVARCHAR(50) NOT NULL DEFAULT 'Running',
  ResultSummary NVARCHAR(MAX) NULL,
  StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  EndedAt DATETIME2 NULL,
  FOREIGN KEY (WorkflowId) REFERENCES WorkflowDefinitions(WorkflowId),
  FOREIGN KEY (StartedByUserId) REFERENCES Users(UserId)
);

CREATE TABLE AuditEvents (
  AuditEventId INT IDENTITY PRIMARY KEY,
  ActorUserId INT NOT NULL,
  EventType NVARCHAR(100) NOT NULL,
  TargetType NVARCHAR(100) NULL,
  TargetId NVARCHAR(100) NULL,
  MetadataJson NVARCHAR(MAX) NULL,
  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  FOREIGN KEY (ActorUserId) REFERENCES Users(UserId)
);

CREATE INDEX IX_Messages_ConversationId_CreatedAt ON Messages(ConversationId, CreatedAt DESC);
CREATE INDEX IX_KnowledgeArticleVersions_ArticleId_VersionNumber ON KnowledgeArticleVersions(ArticleId, VersionNumber DESC);
CREATE INDEX IX_AuditEvents_Actor_CreatedAt ON AuditEvents(ActorUserId, CreatedAt DESC);
