/**
 * Copyright (c) 2009, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

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