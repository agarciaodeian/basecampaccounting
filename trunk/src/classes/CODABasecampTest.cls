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
 * CODABasecampTest
 ************************************************************************/
public class CODABasecampTest 
{
	public static testmethod void testController()
	{
		// TODO: Perform some assertions! :-)
		CODABasecamp.setTestMode(true);
		CODABasecampWizardController controller = new CODABasecampWizardController();
		controller.SelectedDimensionProject = '1';
		controller.SelectedDimensionTodoList = '2';
		controller.SelectedDimensionPerson = '3';
		controller.next(); // Step 0
		controller.next(); // Step 1
		controller.next(); // Step 2
		controller.next(); // Step 3
		controller.next(); // Step 4
		controller.next(); // Step 5
	}
	
	public static void testProjectsList()
	{
		// Basecamp connection
		CODABasecamp.Connection connection = new CODABasecamp.Connection();
		connection.BaseURL = 'https://domain.basecamphq.com';
		connection.UserName = 'user';
		connection.Password = 'password';
		connection.Debug = true;
		
		// List Projects
		List<CODABasecamp.ProjectEntry> projects = CODABasecamp.getProjects(connection);
		if(projects!=null)
		{
			for(CODABasecamp.ProjectEntry project : projects)
			{
				System.Debug('');
				System.Debug(project.Name + ' (' + project.Company.Name + ')');
				
				// List People in this project
				List<CODABasecamp.Person> people = project.getPeople();
				if(people!=null && people.Size() > 0)
				{
					System.Debug('');
					System.Debug('  **** People ****');
					System.Debug('');					
					for(CODABasecamp.Person person : people)
					{
						System.Debug('  ' +
							person.FirstName + ' ' + 
							person.LastName + ' (' +
							person.ID); 
					}
				}
				
				// List Time Entries in this project
				List<CODABasecamp.TimeEntry> timeEntries = project.getTimeEntries(); 
				if(timeEntries!=null && timeEntries.Size() > 0)
				{
					System.Debug('');					
					System.Debug('  **** Time ****');
					System.Debug('');						
					for(CODABasecamp.TimeEntry timeEntry : timeEntries)
					{
						System.Debug('  ' +
							timeEntry.PersonID + ',' + 
							timeEntry.EntryDate + ',' + 
							timeEntry.Hours + ',' + 
							timeEntry.Description);
					}
				}			
				
				// List Todo Lists in this project
				List<CODABasecamp.TodoList> todoLists = project.getTodoLists();
				if(todoLists!=null && todoLists.Size() > 0)	
				{
					System.Debug('');					
					System.Debug('  **** Todo Lists ****');
					System.Debug('');										
					for(CODABasecamp.TodoList todoList : todoLists)
					{
						System.Debug('  ' +
							todoList.ID + ',' + 
							todoList.Name + ',' + 
							todoList.Description);
						System.Debug('');					
						System.Debug('     **** Todo List Items ****');
						System.Debug('');
						for(CODABasecamp.TodoItem todoItem : todoList.TodoItems)
						{																	 
							System.Debug('    ' +
								todoItem.ID + ',' + 
								todoItem.Content);
						}
					}
				}
			}
		}
	}
}