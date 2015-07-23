
```
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
```