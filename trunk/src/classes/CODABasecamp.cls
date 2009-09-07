/***********************************************************************
 * Copyright © 2009 CODA.  All rights reserved.
 *
 * You have a royalty-free right to use, modify, reproduce and distribute
 * the Sample Application Files (and/or any modified version) in any way
 * you find useful for your own internal business purposes, provided that
 * you agree that CODA has no warranty,obligations or liability for any
 * Sample Application Files.
 *
 ************************************************************************/

/************************************************************************
 * CODABasecamp
 *
 * Small library around the Basecamp API
 ************************************************************************/
public class CODABasecamp 
{
	private static Boolean s_testMode = false;
	
	//
	// Enable canned responses from makeRequest to enable testing
	//
	public static void setTestMode(Boolean testMode)
	{
		s_testMode = testMode;
	}
	
	// 
	// Test mode enabled?
	//
	public static Boolean isTestMode()
	{
		return s_testMode;
	}
	
	//
	// A connection to Basecamp
	//	
	public class Connection
	{
		public String BaseURL { get; set; }
		public String UserName { get; set; }
		public String Password { get; set; }
		public Boolean Debug { get; set; }
		
		public Connection()
		{
			Debug = false;
		}
	}
	
	// From http://developer.37signals.com/basecamp/reference.shtml
	//
	// <project>
  	//   <id type="integer">#{id}</id>
  	//   <name>#{name}</name>
  	//   <created-on type="datetime">#{created_on}</created-on>
  	//   <status>#{status}</status>
  	//   <last-changed-on type="datetiem">#{last_changed_on}</last-changed-on>
  	//   <company>
	//     <id type="integer">#{id}</id>
	//     <name>#{name}</name>
	//   </company>
	//   <!-- if user is administrator, or show_announcement is true -->
	//   <announcement>#{announcement}</announcement>
	//   <!-- if user is administrator -->
	//   <start-page>#{start_page}</start-page>
	//   <show-writeboards type="boolean">#{show_writeboards}</show-writeboards>
	//   <show-announcement type="boolean">#{show_announcement}</show-announcement>
	// </project>	
	public class ProjectEntry
	{
		public Connection Connection { get; set; }
		public String ID { get; set; }
		public String Name { get; set; }
		public String CreatedOn { get; set; }
		public String Status { get; set; }
		public String LastChangedOn { get; set; }
		public ProjectCompany Company { get; set; }
		public String Announcement { get; set; }
		public String StartPage { get; set; }
		public String ShowWriteBoards { get; set; }
		public String ShowAnnouncement { get; set; }
		
		public ProjectEntry(Connection connection, XmlStreamReader reader)
		{
			this.Connection = connection;
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
				{
					if(reader.getLocalName() == 'id')
					{
						reader.next();
						if(reader.isCharacters())				
							ID = reader.getText();
					}
					else if(reader.getLocalName() == 'name')
					{
						reader.next();
						if(reader.isCharacters())				
							Name = reader.getText();
					}
					else if(reader.getLocalName() == 'created-on')
					{
						reader.next();
						if(reader.isCharacters())				
							CreatedOn = reader.getText();
					}
					else if(reader.getLocalName() == 'status')
					{
						reader.next();
						if(reader.isCharacters())				
							Status = reader.getText();
					}
					else if(reader.getLocalName() == 'last-changed-on')
					{
						reader.next();
						if(reader.isCharacters())				
							LastChangedOn = reader.getText();
					}
					else if(reader.getLocalName() == 'company')
					{
						Company = new ProjectCompany(reader);
					}					
					else if(reader.getLocalName() == 'announcement')
					{
						reader.next();
						if(reader.isCharacters())				
							Announcement = reader.getText();
					}
					else if(reader.getLocalName() == 'start-page')
					{
						reader.next();
						if(reader.isCharacters())				
							StartPage = reader.getText();
					}
					else if(reader.getLocalName() == 'show-writeboards')
					{
						reader.next();
						if(reader.isCharacters())				
							ShowWriteBoards = reader.getText();
					}
					else if(reader.getLocalName() == 'show-announcement')
					{
						reader.next();
						if(reader.isCharacters())				
							ShowAnnouncement = reader.getText();
					}
				}		
				if (reader.getEventType() == XmlTag.END_ELEMENT)
					if(reader.getLocalName() == 'project')
						break;
				reader.next();					
			}						
		}

		// 
		// List people for this project
		//
		public List<Person> getPeople()
		{
			// Make Basecamp HTTP request
			String response = CODABasecamp.makeRequest(Connection, 'projects/' + ID + '/contacts/people/' + Company.ID);			
			
			// Parse response
			XmlStreamReader reader = new XmlStreamReader(response);
			List<Person> people = new List<Person>();
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
					if(reader.getLocalName() == 'person')
						people.add(new CODABasecamp.Person(reader));
				reader.next();
			}		 				
			return people;
		}
		
		// 
		// List time entires for this project
		//		
		public List<TimeEntry> getTimeEntries()
		{
			// Make Basecamp HTTP request
			String response = CODABasecamp.makeRequest(Connection,'projects/' + ID + '/time_entries.xml');			
						
			// Parse response
			XmlStreamReader reader = new XmlStreamReader(response);
			List<TimeEntry> timeEntries = new List<TimeEntry>();
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
					if(reader.getLocalName() == 'time-entry')
						timeEntries.add(new CODABasecamp.TimeEntry(reader));
				reader.next();
			}		 				
			return timeEntries;			
		}		
		
		// 
		// List TODO Lists
		//
		public List<TodoList> getTodoLists()
		{
			// Make Basecamp HTTP request
			String response = CODABasecamp.makeRequest(Connection, 'projects/' + ID + '/todo_lists.xml');			
						
			// Parse response
			XmlStreamReader reader = new XmlStreamReader(response);
			List<TodoList> todoLists = new List<TodoList>();
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
					if(reader.getLocalName() == 'todo-list')
						todoLists.add(new CODABasecamp.TodoList(reader));
				reader.next();
			}		 				
			return todoLists;			
		}

		// 
		// Retrieve a specific Todo List (with todo items)
		//		
		public TodoList getTodoList(String Id)
		{
			// Make Basecamp HTTP request
			String response = CODABasecamp.makeRequest(Connection, 'todo_lists/' + Id + '.xml');			
						
			// Parse response
			XmlStreamReader reader = new XmlStreamReader(response);
			return new CODABasecamp.TodoList(reader);
		}
	}
	
	// From http://developer.37signals.com/basecamp/reference.shtml
	//
  	//   <company>
	//     <id type="integer">#{id}</id>
	//     <name>#{name}</name>
	//   </company>
	//
	public class ProjectCompany
	{
		public String ID { get; set; }
		public String Name { get; set; }
		
		public ProjectCompany(XmlStreamReader reader)
		{
			reader.next();
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
				{
					if(reader.getLocalName() == 'id')
					{
						reader.next();
						if(reader.isCharacters())				
							ID = reader.getText();
					}
					else if(reader.getLocalName() == 'name')
					{
						reader.next();
						if(reader.isCharacters())				
							Name = reader.getText();
					}
				}
				if (reader.getEventType() == XmlTag.END_ELEMENT)
					if(reader.getLocalName() == 'company')
						break;
				reader.next();
			}
		}		
	}
	
	// From http://developer.37signals.com/basecamp/reference.shtml
	//
	// <time-entry>
  	//	<id type="integer">#{id}</id>
  	//	<project-id type="integer">#{project-id}</project-id>
  	//	<person-id type="integer">#{person-id}</person-id>
  	//	<date type="date">#{date}</date>
  	//	<hours>#{hours}</hours>
  	//	<description>#{description}</description>
  	//	<todo-item-id type="integer">#{todo-item-id}</todo-item-id>
	// </time-entry>	
	//
	public class TimeEntry
	{
		public String ID { get; set; }
		public String ProjectID { get; set; }
		public String PersonID { get; set; }
		public String EntryDate { get; set; }
		public String Hours { get; set; }
		public String Description { get; set; }
		public String TodoItemId { get; set; }
		
		public TimeEntry(XmlStreamReader reader)
		{
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
				{
					if(reader.getLocalName() == 'id')
					{
						reader.next();
						if(reader.isCharacters())				
							ID = reader.getText();
					}
					else if(reader.getLocalName() == 'project-id')
					{
						reader.next();
						if(reader.isCharacters())				
							ProjectID = reader.getText();
					}
					else if(reader.getLocalName() == 'person-id')
					{
						reader.next();
						if(reader.isCharacters())				
							PersonID = reader.getText();
					}
					else if(reader.getLocalName() == 'date')
					{
						reader.next();
						if(reader.isCharacters())				
							EntryDate = reader.getText();
					}
					else if(reader.getLocalName() == 'hours')
					{
						reader.next();
						if(reader.isCharacters())				
							Hours = reader.getText();
					}
					else if(reader.getLocalName() == 'description')
					{
						reader.next();
						if(reader.isCharacters())				
							Description = reader.getText();
					}
					else if(reader.getLocalName() == 'todo-item-id')
					{
						reader.next();
						if(reader.isCharacters())				
							TodoItemId = reader.getText();
					}
				}		
				if (reader.getEventType() == XmlTag.END_ELEMENT)
					if(reader.getLocalName() == 'time-entry')
						break;
				reader.next();					
			}						
		}
		 
	}

	// From http://developer.37signals.com/basecamp/reference.shtml
	//
	//<person>
	//  <id type="integer">#{id}</id>
	//  <first-name>#{first_name}</first-name>
	//  <last-name>#{last_name}</last-name>
	//  <title>#{title}</title>
	//  <email-address>#{email_address}</email-address}
	//  <im-handle>#{im_handle}</im-handle>
	//  <im-service>#{im_service}</im-service>
	//  <phone-number-office>#{phone_number_office}</phone-number-office>
	//  <phone-number-office-ext>#{phone_number_office_ext}</phone-number-office-ext>
	//  <phone-number-mobile>#{phone_number_mobile}</phone-number-mobile>
	//  <phone-number-home>#{phone_number_home}</phone-number-home>
	//  <phone-number-fax>#{phone_number_fax}</phone-number-fax>
	//  <last-login type="datetime">#{last_login}</last-login>
	//  <client-id type="integer">#{client_id}</client-id>
	//  <!-- if user is an administrator, or is self -->
	//  <user-name>#{user_name}</user-name>
	//  <!-- if user is self -->
	//  <password>#{password}</password>
	//  <token>#{token}</token>
	//  <!-- if user is an administrator -->
	//  <administrator type="boolean">#{administrator}</administrator>
	//  <deleted type="boolean">#{deleted}</deleted>
	//  <has-access-to-new-projects type="boolean">#{has_access_to_new_projects}</has-access-to-new-projects>
	//</person>	
	public class Person
	{
		public String ID { get; set; }
		public String FirstName { get; set; }
		public String LastName { get; set; }
		
		public Person(XmlStreamReader reader)
		{
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
				{
					if(reader.getLocalName() == 'id')
					{
						reader.next();
						if(reader.isCharacters())				
							ID = reader.getText();
					}
					else if(reader.getLocalName() == 'first-name')
					{
						reader.next();
						if(reader.isCharacters())				
							FirstName = reader.getText();
					}
					else if(reader.getLocalName() == 'last-name')
					{
						reader.next();
						if(reader.isCharacters())				
							LastName = reader.getText();
					}
				}		
				if (reader.getEventType() == XmlTag.END_ELEMENT)
					if(reader.getLocalName() == 'person')
						break;
				reader.next();					
			}						
		}
	}
	
	// From http://developer.37signals.com/basecamp/reference.shtml
	//
	// <todo-list>
	//   <id type="integer">#{id}</id>
	//   <name>#{name}</name>
	//   <description>#{description}</description>
	//   <project-id type="integer">#{project_id}</project-id>
	//   <milestone-id type="integer">#{milestone_id}</milestone-id>
	//   <position type="integer">#{position}</position>
	//   <!-- if user can see private lists -->
	//   <private type="boolean">#{private}</private>
	//   <!-- if the account supports time tracking -->
	//   <tracked type="boolean">#{tracked}</tracked>
	//   <!-- if todo-items are included in the response -->
	//   <todo-items type="array">
	//     <todo-item>
	//       ...
	//     </todo-item>
	//     <todo-item>
	//       ...
	//     </todo-item>
	//     ...
	//   </todo-items>
	// </todo-list>
	//	
	public class TodoList
	{
		public String ID { get; set; }
		public String Name { get; set; } 
		public String Description { get; set; }
		public String ProjectID { get; set; }
		public String MilestoneID { get; set; }
		public String Position { get; set; }
		public String TodoListPrivate { get; set; }
		public String Tracked { get; set; }
		public List<TodoItem> TodoItems { get; set ; }
		
		public TodoList(XmlStreamReader reader)
		{
			TodoItems = new List<TodoItem>();
			
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
				{
					if(reader.getLocalName() == 'id')
					{
						reader.next();
						if(reader.isCharacters())				
							ID = reader.getText();
					}
					else if(reader.getLocalName() == 'name')
					{
						reader.next();
						if(reader.isCharacters())				
							Name = reader.getText();
					}
					else if(reader.getLocalName() == 'description')
					{
						reader.next();
						if(reader.isCharacters())				
							Description = reader.getText();
					}
					else if(reader.getLocalName() == 'project-id')
					{
						reader.next();
						if(reader.isCharacters())				
							ProjectID = reader.getText();
					}
					else if(reader.getLocalName() == 'milestone-id')
					{
						reader.next();
						if(reader.isCharacters())				
							MilestoneID = reader.getText();
					}
					else if(reader.getLocalName() == 'position')
					{
						reader.next();
						if(reader.isCharacters())				
							Position = reader.getText();
					}
					else if(reader.getLocalName() == 'private')
					{
						reader.next();
						if(reader.isCharacters())				
							TodoListPrivate = reader.getText();
					}
					else if(reader.getLocalName() == 'tracked')
					{
						reader.next();
						if(reader.isCharacters())				
							Tracked = reader.getText();
					}
					else if(reader.getLocalName() == 'todo-items')
					{
						// Consume <todo-items>
						reader.next();
						while(reader.hasNext())
						{
							if(reader.getEventType() == XmlTag.START_ELEMENT)
							{
								if(reader.getLocalName() == 'todo-item')
								{
									TodoItem todoItem = new TodoItem(reader);
									TodoItems.add(todoItem);
								}
							}
							else if(reader.getEventType() == XmlTag.END_ELEMENT)
								if(reader.getLocalName() == 'todo-items')
									break;
							reader.next();
						}
					}
					
				}		
				if (reader.getEventType() == XmlTag.END_ELEMENT)
					if(reader.getLocalName() == 'todo-list')
						break;
				reader.next();					
			}						
		}		
	}
	
	//<todo-item>
	//  <id type="integer">#{id}</id>
	//  <content>#{content}</content>
	//  <position type="integer">#{position}</position>
	//  <created-on type="datetime">#{created_on}</created-on>
	//  <creator-id type="integer">#{creator_id}</creator-id>
	//  <completed type="boolean">#{completed}</completed>
	//  <!-- if the item has a responsible party -->
	//  <responsible-party-type>#{responsible_party_type}</responsible-party-type>
	//  <responsible-party-id type="integer">#{responsible_party_id}</responsible-party-id>
	//  <!-- if the item has been completed -->
	//  <completed-on type="datetime">#{completed_on}</completed-on>
	//  <completer-id type="integer">#{completer_id}</completer-id>
	//</todo-item>	
	public class TodoItem
	{
		public String ID { get; set; }
		public String Content { get; set; }
		public String Position { get; set; }
		public String CreatedOn { get; set; }
		public String CreatorID { get; set; }
		public String Completed { get; set; }
		public String ResponsiblePartyType { get; set; }
		public String ResponsiblePartyID { get; set; }
		public String CompletedOn { get; set; }
		public String CompletedId { get; set; }
			
		public TodoItem(XmlStreamReader reader)
		{
			reader.next();
			while(reader.hasNext())
			{
				if (reader.getEventType() == XmlTag.START_ELEMENT)
				{
					if(reader.getLocalName() == 'id')
					{
						reader.next();
						if(reader.isCharacters())				
							ID = reader.getText();
					}
					else if(reader.getLocalName() == 'content')
					{
						reader.next();
						if(reader.isCharacters())				
							Content = reader.getText();
					}
					else if(reader.getLocalName() == 'position')
					{
						reader.next();
						if(reader.isCharacters())				
							Position = reader.getText();
					}
					else if(reader.getLocalName() == 'created-on')
					{
						reader.next();
						if(reader.isCharacters())				
							CreatedOn = reader.getText();
					}
					else if(reader.getLocalName() == 'creator-id')
					{
						reader.next();
						if(reader.isCharacters())				
							CreatorID = reader.getText();
					}
					else if(reader.getLocalName() == 'completed')
					{
						reader.next();
						if(reader.isCharacters())				
							Completed = reader.getText();
					}
					else if(reader.getLocalName() == 'responsible-party-type')
					{
						reader.next();
						if(reader.isCharacters())				
							ResponsiblePartyType = reader.getText();
					}
					else if(reader.getLocalName() == 'responsible-party-id')
					{
						reader.next();
						if(reader.isCharacters())				
							ResponsiblePartyId = reader.getText();
					}
					else if(reader.getLocalName() == 'completed-on')
					{
						reader.next();
						if(reader.isCharacters())				
							CompletedOn = reader.getText();
					}
					else if(reader.getLocalName() == 'completed-id')
					{
						reader.next();
						if(reader.isCharacters())				
							CompletedId = reader.getText();
					}
				}
				if (reader.getEventType() == XmlTag.END_ELEMENT)
					if(reader.getLocalName() == 'todo-item')
						break;
				reader.next();
			}
		}		
	}
			
	//
	// See http://developer.37signals.com/basecamp/projects.shtml
	//
	public static List<ProjectEntry> getProjects(CODABasecamp.Connection connection)
	{
		// Make Basecamp HTTP request
		String response = CODABasecamp.makeRequest(connection, 'projects.xml');
		
		// Parse response
		XmlStreamReader reader = new XmlStreamReader(response);
		List<ProjectEntry> projects = new List<ProjectEntry>();
		while(reader.hasNext())
		{
			if (reader.getEventType() == XmlTag.START_ELEMENT)
				if(reader.getLocalName() == 'project')
					projects.add(new CODABasecamp.ProjectEntry(connection, reader));
			reader.next();
		}		 				
		return projects;
	}
	
	//
	// Prepare a HTTP request for communication with the Basecamp API
	//
	private static String makeRequest(CODABasecamp.Connection connection, String resource)
	{
		// Test mode?
		if(s_testMode)
		{
			if(resource.endsWith('projects.xml'))
				return '<?xml version="1.0" encoding="UTF-8"?>' + 
					   '<projects type="array">' +
						  '<project>' +
						    '<announcement>Welcome to the Merlinauto Basecamp project for the Hogan Repairs Classic Restoration Project. </announcement>' +
						    '<created-on type="date">2009-02-22</created-on>' +
						    '<id type="integer">2943412</id>' +
						    '<last-changed-on type="datetime">2009-02-23T12:18:46Z</last-changed-on>' +
						    '<name>Hogan Repairs Car Restoration</name>' +
						    '<show-announcement type="boolean">true</show-announcement>' +
						    '<show-writeboards type="boolean">true</show-writeboards>' +
						    '<start-page>log</start-page>' +
						    '<status>active</status>' +
						    '<company>' +
						      '<id type="integer">1259456</id>' +
						      '<name>CODA 2go</name>' +
						    '</company>' +
						  '</project>' +
						'</projects>';
			else if(resource.endsWith('projects/2943412/contacts/people/1259456'))
				return '<people type="array">' +
					   '<person>' +
					   '<administrator type="boolean">true</administrator>' +
					   '<client-id type="integer">0</client-id>' +
					   '<deleted type="boolean">false</deleted>' +
					   '<email-address>albert.shattuck@coda.com</email-address>' +
					   '<first-name>AJ</first-name>' +
					   '<has-access-to-new-projects type="boolean">false</has-access-to-new-projects>' +
					   '<id type="integer">3451050</id>' +
					   '<identity-url nil="true"></identity-url>' +
					   '<im-handle></im-handle>' +
					   '<im-service>AOL</im-service>' +
					   '<last-name>Shattuck</last-name>' +
					   '<phone-number-fax></phone-number-fax>' +
					   '<phone-number-home></phone-number-home>' +
					   '<phone-number-mobile></phone-number-mobile>' +
					   '<phone-number-office></phone-number-office>' +
					   '<phone-number-office-ext></phone-number-office-ext>' +
					   '<title>Senior Application Consultant</title>' +
					   '<user-name>ashattuck</user-name>' +
					   '<uuid>2c1412da-21e0-33fd-a9b5-142f714ca610</uuid>' +
					 '</person>' +
					 '<person>' +
					   '<administrator type="boolean">false</administrator>' +
					   '<client-id type="integer">0</client-id>' +
					   '<deleted type="boolean">false</deleted>' +
					   '<email-address>debbie.ashton@coda.com</email-address>' +
					   '<first-name>Debbie</first-name>' +
					   '<has-access-to-new-projects type="boolean">false</has-access-to-new-projects>' +
					   '<id type="integer">3426070</id>' +
					   '<identity-url nil="true"></identity-url>' +
					   '<im-handle></im-handle>' +
					   '<im-service>AOL</im-service>' +
					   '<last-name>Ashton</last-name>' +
					   '<phone-number-fax></phone-number-fax>' +
					   '<phone-number-home></phone-number-home>' +
					   '<phone-number-mobile></phone-number-mobile>' +
					   '<phone-number-office></phone-number-office>' +
					   '<phone-number-office-ext></phone-number-office-ext>' +
					   '<title></title>' +
					   '<user-name>dashton</user-name>' +
					   '<uuid>2c1412da-21e0-33fd-a9b5-142f714ca610</uuid>' +
					 '</person>' +
					 '<person>' +
					   '<administrator type="boolean">false</administrator>' +
					   '<client-id type="integer">0</client-id>' +
					   '<deleted type="boolean">false</deleted>' +
					   '<email-address>andrew.firth@coda.com</email-address>' +
					   '<first-name>Andrew</first-name>' +
					   '<has-access-to-new-projects type="boolean">false</has-access-to-new-projects>' +
					   '<id type="integer">3426049</id>' +
					   '<identity-url nil="true"></identity-url>' +
					   '<im-handle></im-handle>' +
					   '<im-service>AOL</im-service>' +
					   '<last-name>Firth</last-name>' +
					   '<phone-number-fax></phone-number-fax>' +
					   '<phone-number-home></phone-number-home>' +
					   '<phone-number-mobile></phone-number-mobile>' +
					   '<phone-number-office></phone-number-office>' +
					   '<phone-number-office-ext></phone-number-office-ext>' +
					   '<title></title>' +
					   '<user-name>afirth</user-name>' +
					   '<uuid>2c1412da-21e0-33fd-a9b5-142f714ca610</uuid>' +
					 '</person>' +
					 '<person>' +
					   '<administrator type="boolean">true</administrator>' +
					   '<client-id type="integer">0</client-id>' +
					   '<deleted type="boolean">false</deleted>' +
					   '<email-address>andrew.fawcett@coda.com</email-address>' +
					   '<first-name>Andrew</first-name>' +
					   '<has-access-to-new-projects type="boolean">false</has-access-to-new-projects>' +
					   '<id type="integer">3426194</id>' +
					   '<identity-url nil="true"></identity-url>' +
					   '<im-handle></im-handle>' +
					   '<im-service>AOL</im-service>' +
					   '<last-name>Fawcett</last-name>' +
					   '<password>smudgecat1</password>' +
					   '<phone-number-fax></phone-number-fax>' +
					   '<phone-number-home></phone-number-home>' +
					   '<phone-number-mobile></phone-number-mobile>' +
					   '<phone-number-office></phone-number-office>' +
					   '<phone-number-office-ext></phone-number-office-ext>' +
					   '<title></title>' +
					   '<user-name>afawcett</user-name>' +
					   '<uuid>2c1412da-21e0-33fd-a9b5-142f714ca610</uuid>' +
					 '</person>' +
					'</people>';
				else if(resource.endsWith('projects/2943412/todo_lists.xml'))
					return '<todo-lists type="array">' +
							 '<todo-list>' +
							   '<completed-count type="integer">0</completed-count>' +
							   '<description>Once the car has been sold there are several jobs that need to be done before the customer can take the car from the showroom</description>' +
							   '<id type="integer">5527167</id>' +
							   '<milestone-id type="integer" nil="true"></milestone-id>' +
							   '<name>Presales services</name>' +
							   '<position type="integer">1</position>' +
							   '<private type="boolean">false</private>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<tracked type="boolean">true</tracked>' +
							   '<uncompleted-count type="integer">4</uncompleted-count>' +
							   '<complete>false</complete>' +
							 '</todo-list>' +
							 '<todo-list>' +
							   '<completed-count type="integer">0</completed-count>' +
							   '<description>Go over the car, find out what new/replacement parts are needed and check what we have in stock.</description>' +
							   '<id type="integer">5524684</id>' +
							   '<milestone-id type="integer" nil="true"></milestone-id>' +
							   '<name>Obtain Replacement Parts</name>' +
							   '<position type="integer">2</position>' +
							   '<private type="boolean">false</private>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<tracked type="boolean">true</tracked>' +
							   '<uncompleted-count type="integer">3</uncompleted-count>' +
							   '<complete>false</complete>' +
							 '</todo-list>' +
							 '<todo-list>' +
							   '<completed-count type="integer">0</completed-count>' +
							   '<description>Tasks involved in getting hold of the car, finding scrap yards, buying the car, paper work etc..</description>' +
							   '<id type="integer">5524678</id>' +
							   '<milestone-id type="integer" nil="true"></milestone-id>' +
							   '<name>Source the Vehicle to Restore</name>' +
							   '<position type="integer">3</position>' +
							   '<private type="boolean">false</private>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<tracked type="boolean">true</tracked>' +
							   '<uncompleted-count type="integer">3</uncompleted-count>' +
							   '<complete>false</complete>' +
							 '</todo-list>' +
							 '<todo-list>' +
							   '<completed-count type="integer">0</completed-count>' +
							   '<description>Tasks that help us get as much background on the car as possible.</description>' +
							   '<id type="integer">5524672</id>' +
							   '<milestone-id type="integer" nil="true"></milestone-id>' +
							   '<name>Gather Background on the Car</name>' +
							   '<position type="integer">4</position>' +
							   '<private type="boolean">false</private>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<tracked type="boolean">true</tracked>' +
							   '<uncompleted-count type="integer">3</uncompleted-count>' +
							   '<complete>false</complete>' +
							 '</todo-list>' +
							'</todo-lists>';
					else if(resource.endsWith('todo_lists/5527167.xml'))
						return 							
							'<todo-list>' +
							 '<completed-count type="integer">0</completed-count>' +
							 '<description>Once the car has been sold there are several jobs that need to be done before the customer can take the car from the showroom</description>' +
							 '<id type="integer">5527167</id>' +
							 '<milestone-id type="integer" nil="true"></milestone-id>' +
							 '<name>Presales services</name>' +
							 '<position type="integer">1</position>' +
							 '<private type="boolean">false</private>' +
							 '<project-id type="integer">2943412</project-id>' +
							 '<tracked type="boolean">true</tracked>' +
							 '<uncompleted-count type="integer">4</uncompleted-count>' +
							 '<todo-items type="array">' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Service the car</content>' +
							     '<created-on type="datetime">2009-02-23T10:02:28Z</created-on>' +
							     '<creator-id type="integer">3426070</creator-id>' +
							     '<id type="integer">32230789</id>' +
							     '<position type="integer">1</position>' +
							     '<todo-list-id type="integer">5527167</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Purchase a tax disc</content>' +
							     '<created-on type="datetime">2009-02-23T10:02:38Z</created-on>' +
							     '<creator-id type="integer">3426070</creator-id>' +
							     '<id type="integer">32230792</id>' +
							     '<position type="integer">2</position>' +
							     '<todo-list-id type="integer">5527167</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Pass MOT</content>' +
							     '<created-on type="datetime">2009-02-23T10:02:53Z</created-on>' +
							     '<creator-id type="integer">3426070</creator-id>' +
							     '<id type="integer">32230804</id>' +
							     '<position type="integer">3</position>' +
							     '<todo-list-id type="integer">5527167</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Clean and valet the car</content>' +
							     '<created-on type="datetime">2009-02-23T10:03:04Z</created-on>' +
							     '<creator-id type="integer">3426070</creator-id>' +
							     '<id type="integer">32230811</id>' +
							     '<position type="integer">4</position>' +
							     '<todo-list-id type="integer">5527167</todo-list-id>' +
							   '</todo-item>' +
							 '</todo-items>' +
							 '<complete>false</complete>' +
							'</todo-list>';
					else if(resource.endsWith('todo_lists/5524684.xml'))
						return 						
							'<todo-list>' +
							 '<completed-count type="integer">0</completed-count>' +
							 '<description>Go over the car, find out what new/replacement parts are needed and check what we have in stock.</description>' +
							 '<id type="integer">5524684</id>' +
							 '<milestone-id type="integer" nil="true"></milestone-id>' +
							 '<name>Obtain Replacement Parts</name>' +
							 '<position type="integer">2</position>' +
							 '<private type="boolean">false</private>' +
							 '<project-id type="integer">2943412</project-id>' +
							 '<tracked type="boolean">true</tracked>' +
							 '<uncompleted-count type="integer">3</uncompleted-count>' +
							 '<todo-items type="array">' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Order parts not in stock</content>' +
							     '<created-on type="datetime">2009-02-22T17:54:16Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215220</id>' +
							     '<position type="integer">1</position>' +
							     '<todo-list-id type="integer">5524684</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Source required parts from stock</content>' +
							     '<created-on type="datetime">2009-02-22T17:54:08Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215218</id>' +
							     '<position type="integer">2</position>' +
							     '<todo-list-id type="integer">5524684</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Check the condition of the car and list required parts</content>' +
							     '<created-on type="datetime">2009-02-22T17:53:57Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215215</id>' +
							     '<position type="integer">3</position>' +
							     '<todo-list-id type="integer">5524684</todo-list-id>' +
							   '</todo-item>' +
							 '</todo-items>' +
							 '<complete>false</complete>' +
							'</todo-list>';													
					else if(resource.endsWith('todo_lists/5524678.xml'))
						return 										
							'<todo-list>' +
							 '<completed-count type="integer">0</completed-count>' +
							 '<description>Tasks involved in getting hold of the car, finding scrap yards, buying the car, paper work etc..</description>' +
							 '<id type="integer">5524678</id>' +
							 '<milestone-id type="integer" nil="true"></milestone-id>' +
							 '<name>Source the Vehicle to Restore</name>' +
							 '<position type="integer">3</position>' +
							 '<private type="boolean">false</private>' +
							 '<project-id type="integer">2943412</project-id>' +
							 '<tracked type="boolean">true</tracked>' +
							 '<uncompleted-count type="integer">3</uncompleted-count>' +
							 '<todo-items type="array">' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Trackdown some scrap yards who might have the car</content>' +
							     '<created-on type="datetime">2009-02-22T17:50:54Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215171</id>' +
							     '<position type="integer">1</position>' +
							     '<todo-list-id type="integer">5524678</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Go view some cars</content>' +
							     '<created-on type="datetime">2009-02-22T17:51:07Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215174</id>' +
							     '<position type="integer">2</position>' +
							     '<todo-list-id type="integer">5524678</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Purchase the car and complete the paper work</content>' +
							     '<created-on type="datetime">2009-02-22T17:51:19Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215177</id>' +
							     '<position type="integer">3</position>' +
							     '<todo-list-id type="integer">5524678</todo-list-id>' +
							   '</todo-item>' +
							 '</todo-items>' +
							 '<complete>false</complete>' +
							'</todo-list>';								
					else if(resource.endsWith('todo_lists/5524672.xml'))
							return '<todo-list>' +
							 '<completed-count type="integer">0</completed-count>' +
							 '<description>Tasks that help us get as much background on the car as possible.</description>' +
							 '<id type="integer">5524672</id>' +
							 '<milestone-id type="integer" nil="true"></milestone-id>' +
							 '<name>Gather Background on the Car</name>' +
							 '<position type="integer">4</position>' +
							 '<private type="boolean">false</private>' +
							 '<project-id type="integer">2943412</project-id>' +
							 '<tracked type="boolean">true</tracked>' +
							 '<uncompleted-count type="integer">3</uncompleted-count>' +
							 '<todo-items type="array">' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Research on the internet</content>' +
							     '<created-on type="datetime">2009-02-22T17:48:01Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215130</id>' +
							     '<position type="integer">1</position>' +
							     '<todo-list-id type="integer">5524672</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Talk to the manufacturer</content>' +
							     '<created-on type="datetime">2009-02-22T17:48:46Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215140</id>' +
							     '<position type="integer">2</position>' +
							     '<todo-list-id type="integer">5524672</todo-list-id>' +
							   '</todo-item>' +
							   '<todo-item>' +
							     '<comments-count type="integer">0</comments-count>' +
							     '<completed type="boolean">false</completed>' +
							     '<content>Find an old owners manual</content>' +
							     '<created-on type="datetime">2009-02-22T17:49:16Z</created-on>' +
							     '<creator-id type="integer">3426194</creator-id>' +
							     '<id type="integer">32215145</id>' +
							     '<position type="integer">3</position>' +
							     '<todo-list-id type="integer">5524672</todo-list-id>' +
							   '</todo-item>' +
							 '</todo-items>' +
							 '<complete>false</complete>' +
							'</todo-list>';	
					else if(resource.endsWith('projects/2943412/time_entries.xml'))
						return 
							'<time-entries type="array">' +
							 '<time-entry>' +
							   '<date type="date">2009-02-23</date>' +
							   '<description></description>' +
							   '<hours type="float">2.0</hours>' +
							   '<id type="integer">13612996</id>' +
							   '<person-id type="integer">3426070</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32230811</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-23</date>' +
							   '<description></description>' +
							   '<hours type="float">8.0</hours>' +
							   '<id type="integer">13612991</id>' +
							   '<person-id type="integer">3426070</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32230804</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-23</date>' +
							   '<description></description>' +
							   '<hours type="float">1.0</hours>' +
							   '<id type="integer">13612989</id>' +
							   '<person-id type="integer">3426070</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32230792</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-23</date>' +
							   '<description></description>' +
							   '<hours type="float">8.0</hours>' +
							   '<id type="integer">13612985</id>' +
							   '<person-id type="integer">3426070</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32230789</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Stripped the car down, made up a list of parts needing replacement.</description>' +
							   '<hours type="float">6.0</hours>' +
							   '<id type="integer">13605724</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215215</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Purchased the car and completed paper work</description>' +
							   '<hours type="float">1.0</hours>' +
							   '<id type="integer">13605722</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215177</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Went to view for possible cards, found a good candidsate.</description>' +
							   '<hours type="float">4.0</hours>' +
							   '<id type="integer">13605720</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215174</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Emailed and called a few local scrap yards, obtained a short list of those to visit.</description>' +
							   '<hours type="float">1.0</hours>' +
							   '<id type="integer">13605717</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215171</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Searched a few local libraries for a copy of the owner manual.</description>' +
							   '<hours type="float">1.0</hours>' +
							   '<id type="integer">13605712</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215145</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Had a conference call with the manufacturer to find out common faults, hard to find parts etc..</description>' +
							   '<hours type="float">1.0</hours>' +
							   '<id type="integer">13605708</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215140</todo-item-id>' +
							 '</time-entry>' +
							 '<time-entry>' +
							   '<date type="date">2009-02-22</date>' +
							   '<description>Spent some time today on Google and Wikipedia reseaching this car.</description>' +
							   '<hours type="float">2.0</hours>' +
							   '<id type="integer">13605703</id>' +
							   '<person-id type="integer">3426194</person-id>' +
							   '<project-id type="integer">2943412</project-id>' +
							   '<todo-item-id type="integer">32215130</todo-item-id>' +
							 '</time-entry>' +
							'</time-entries>';
			return null; 
		}
		
		// Url
		HttpRequest req = new HttpRequest();
		req.setEndpoint(connection.BaseURL+'/'+resource);
		req.setMethod('GET');
		     
		// Specify the required user name and password to access the endpoint
		// As well as the header and header information
		String username = connection.UserName;
		String password = connection.Password;		  
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Content-Type', 'application/xml');
		req.setHeader('Accept', 'application/xml');
		req.setHeader('Authorization', authorizationHeader);

		// Create a new http object to send the request object
		// A response object is generated as a result of the request    
		Http http = new Http();
		if(connection.Debug)
			System.Debug(req.getEndPoint());
		HttpResponse res = http.send(req);
		String body = res.getBody();
		if(connection.Debug)
			System.Debug(body);
		return body;
	}	
}