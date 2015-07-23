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
 * CODABasecampWizardController
 *
 * Demo of CODABasecamp API class that retrieves time entries and produces
 * a CODA 2go Invoice from them
 ************************************************************************/
public class CODABasecampWizardController
{
	// View state and properties bound to page elements
	public Integer Step { get; set; }
	public String SelectedProjectID { get; set; }
	public String SelectedDimensionProject { get; set; }
	public String SelectedDimensionTodoList { get; set; }
	public String SelectedDimensionPerson { get; set; }
	public CODABasecamp.Connection Connection { get; set; }
	public CODABasecamp.ProjectEntry SelectedProject { get; set; }
	public List<CODABasecamp.ProjectEntry> Projects { get; set; }
	public List<SelectTodoList> TodoLists { get; set; }
	public List<SelectTimeEntry> TimeEntires { get; set; }
	public List<SelectOption> DimensionList { get; set; }
	public List<ReviewInvoiceLineItem> ReviewInvoiceLineItems { get; set; }
	public c2g__codaLookup__c Lookup { get; set; }
	private Map<String, CODABasecamp.Person> m_peopleMap;

	public CODABasecampWizardController()
	{
		// Defult connection details
		Connection = new CODABasecamp.Connection();
		Connection.UserName = 'user';
		Connection.Password = 'password';
		Connection.BaseURL = 'https://domain.basecamphq.com';
		connection.Debug = true;

		// Set properties bound to page
		Step = 0;

		// Initialise view state
		m_peopleMap = new Map<String, CODABasecamp.Person>();
	}

	public PageReference Next()
	{
		//try
		//{
			// Login
			if (Step == 0)
			{
				// List projects and default selection to first
				Projects = CODABasecamp.getProjects(Connection);
				if(Projects.Size() > 0)
					SelectedProjectID = Projects[0].ID;

				// Default to project called 'Product Discussion Forum' for demo purposes
				for(CODABasecamp.ProjectEntry project : Projects)
					if(project.Name == 'Hogan Repairs Car Restoration')
						SelectedProjectID = project.ID;
			}
			// Select Project and Dimension to map to
			else if (Step == 1)
			{
				// Retrieve for selected Project the Todo Lists and People working on it
				TodoLists = new List<SelectTodoList>();
 	 			for(CODABasecamp.ProjectEntry project : Projects)
 	 			{
 	 				// Selected project?
 	 				if(project.ID == SelectedProjectID)
 	 				{
 	 					// Filter for Todo Lists on this project with time tracking enabled
						SelectedProject = project;
						for(CODABasecamp.TodoList todoList : SelectedProject.getTodoLists())
							if(todoList.Tracked != null && todoList.Tracked == 'true')
								TodoLists.add(new SelectTodoList(todoList));
		 	 			if( TodoLists.Size() == 0 )
		 	 				throw new WizardException('The selected project must have at least one todo list that is time tracked.');

						// Retrieve a list of the People in the project (used later)
						List<CODABasecamp.Person> people = SelectedProject.getPeople();
						m_peopleMap.clear();
						for(CODABasecamp.Person person : people)
							m_peopleMap.put(person.Id, person);

						// Done
						break;
 	 				}
 	 			}
			}
			// Select Todo Lists and Dimension to map to
			else if (Step == 2)
			{
				// Retrieve todo items for selected todo lists
				List<CODABasecamp.TodoList> selectedTodoLists = new List<CODABasecamp.TodoList>();
				for(SelectTodoList selectedTodoList : TodoLists)
					if(selectedTodoList.Selected)
						selectedTodoLists.add(SelectedProject.getTodoList(selectedTodoList.TodoList.Id));

				// Build a list of selected Todo Item's (later we can add filtering e.g. completed only)
				Map<String, CODABasecamp.TodoList> selectedTodoItemIds = new Map<String, CODABasecamp.TodoList>();
				for(CODABasecamp.TodoList todoList : selectedTodoLists)
					for(CODABasecamp.TodoItem todoItem : todoList.TodoItems)
						selectedTodoItemIds.put(todoItem.Id, todoList);

				// Retrieve time entries for selected project
				List<CODABasecamp.TimeEntry> timeEntries = SelectedProject.getTimeEntries();

				// Display only time entries for todo items from selected lists
				TimeEntires = new List<SelectTimeEntry>();
				for(CODABasecamp.TimeEntry timeEntry : timeEntries)
					if(selectedTodoItemIds.containsKey (timeEntry.TodoItemId))
						TimeEntires.add(new SelectTimeEntry(m_peopleMap.get(timeEntry.PersonID), timeEntry, selectedTodoItemIds.get(timeEntry.TodoItemId)));
 	 			if( TimeEntires.Size() == 0 )
 	 				throw new WizardException('There are no time entries made against the selected todo lists');
			}
			// Select Time Entries and Dimension to map Persons to
			else if (Step == 3)
			{
				// Setup invoice line items for review
				ReviewInvoiceLineItems = new List<ReviewInvoiceLineItem>();
				for(SelectTimeEntry timeEntry : TimeEntires)
					if(timeEntry.Selected)
						ReviewInvoiceLineItems.add(new ReviewInvoiceLineItem(timeEntry.Person, timeEntry.TimeEntry, timeEntry.TodoList));

				// Prompt for Account and Products to post Invoice against
				List<String> companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
				Lookup = new c2g__codaLookup__c();
				try
				{
					// Attempt to default Account and Product fields for demo purposes
					Date now = System.now().date();
					Lookup.Account__c = [select id from Account where Name = 'Algernon Partners & Co'][0].Id;
					Lookup.Product__c = [select id from Product2 where Name = 'Annual Service Contract'][0].Id;
					Lookup.Currency__c = [select id from c2g__codaAccountingCurrency__c where Name = 'USD' and c2g__OwnerCompany__r.Name = :companies[0]][0].Id;
					Lookup.Period__c = [select id from c2g__codaPeriod__c where Name = '2010/001'][0].Id;
				}
				catch (Exception e)
				{
					// Its OK to fail defaulting
				}
			}
			// Create Invoice
			else if (Step == 4)
			{
				// Retrieve price book info for chosen product and currency
				string currencyIso = null;
				double unitPrice = 0;
				try
				{
					// Currency ISO
					currencyIso =
						[select Name from c2g__codaAccountingCurrency__c where Id = :Lookup.Currency__c][0].Name;
					// Unit Price
					unitPrice =
						[select UnitPrice, Product2Id, CurrencyIsoCode
						 from PricebookEntry
						 where Product2Id = :Lookup.Product__c and CurrencyIsoCode = :currencyIso][0].UnitPrice;
				}
				catch (Exception e)
				{
					// For demo, not an issue if the price cannot be found, will defult to 0, then can be edited
				}

				// Ordinal position (base 0) of project, todo list and person dimensions
				Integer projectDimensionIdx = Integer.valueOf(SelectedDimensionProject) - 1;
				Integer todoDimensionIdx = Integer.valueOf(SelectedDimensionTodoList) - 1;
				Integer personDimensionIdx = Integer.valueOf(SelectedDimensionPerson) - 1;

				// Calculate distint dimension names
				List<Map<String, DimensionInfo>> dimensions = new List<Map<String, DimensionInfo>>();
				dimensions.add(new Map<String, DimensionInfo>());
				dimensions.add(new Map<String, DimensionInfo>());
				dimensions.add(new Map<String, DimensionInfo>());
				dimensions.add(new Map<String, DimensionInfo>());
				for(ReviewInvoiceLineItem reviewInvoiceLineItem : ReviewInvoiceLineItems)
				{
					String projectName = SelectedProject.Name;
					String projectId = SelectedProject.ID;
					String todoListName = reviewInvoiceLineItem.TodoList.Name;
					String todoListId = reviewInvoiceLineItem.TodoList.ID;
					String personName = reviewInvoiceLineItem.Person.FirstName + ' ' + reviewInvoiceLineItem.Person.LastName;
					String personId = reviewInvoiceLineItem.Person.ID;
					DimensionInfo project = new DimensionInfo();
					project.Name = projectName;
					project.Id = projectId;
					DimensionInfo todoList = new DimensionInfo();
					todoList.Name = todoListName;
					todoList.Id = todoListId;
					DimensionInfo person = new DimensionInfo();
					person.Name = personName;
					person.Id = personId;
					dimensions[projectDimensionIdx].put(projectName, project);
					dimensions[todoDimensionIdx].put(todoListName, todoList);
					dimensions[personDimensionIdx].put(personName, person);
				}

				// Prepare required dimensions for upsert
				List<c2g.CODAAPIDimension_3_0.Dimension> dimension1 = new List<c2g.CODAAPIDimension_3_0.Dimension>();
				List<c2g.CODAAPIDimension_3_0.Dimension> dimension2 = new List<c2g.CODAAPIDimension_3_0.Dimension>();
				List<c2g.CODAAPIDimension_3_0.Dimension> dimension3 = new List<c2g.CODAAPIDimension_3_0.Dimension>();
				List<c2g.CODAAPIDimension_3_0.Dimension> dimension4 = new List<c2g.CODAAPIDimension_3_0.Dimension>();
				Integer dimensionIdx = 1;
				for(Map<String, DimensionInfo> dimensionNames : dimensions)
				{
					for(DimensionInfo dimensionInfo : dimensionNames.values())
					{
						String dimensionName = dimensionInfo.Name;
						String dimensionId = dimensionInfo.Id;
						if(dimensionIdx == 1)
						{
							// Create a Dimension 1 record
							c2g.CODAAPIDimension_3_0.Dimension dimension = new c2g.CODAAPIDimension_3_0.Dimension();
							dimension.Name = dimensionName;
							dimension.CurrencyIsoCode = currencyIso;
							dimension.ReportingCode = dimensionId;
							dimension.ExternalId = dimensionId;
							dimension1.add(dimension);
						}
						else if(dimensionIdx == 2)
						{
							// Create a Dimension 2 record
							c2g.CODAAPIDimension_3_0.Dimension dimension = new c2g.CODAAPIDimension_3_0.Dimension();
							dimension.Name = dimensionName;
							dimension.CurrencyIsoCode = currencyIso;
							dimension.ReportingCode = dimensionId;
							dimension.ExternalId = dimensionId;
							dimension2.add(dimension);
						}
						else if(dimensionIdx == 3)
						{
							// Create a Dimension 3 record
							c2g.CODAAPIDimension_3_0.Dimension dimension = new c2g.CODAAPIDimension_3_0.Dimension();
							dimension.Name = dimensionName;
							dimension.CurrencyIsoCode = currencyIso;
							dimension.ReportingCode = dimensionId;
							dimension.ExternalId = dimensionId;
							dimension3.add(dimension);
						}
						else if(dimensionIdx == 4)
						{
							// Create a Dimension 4 record
							c2g.CODAAPIDimension_3_0.Dimension dimension = new c2g.CODAAPIDimension_3_0.Dimension();
							dimension.Name = dimensionName;
							dimension.CurrencyIsoCode = currencyIso;
							dimension.ReportingCode = dimensionId;
							dimension.ExternalId = dimensionId;
							dimension4.add(dimension);
						}
					}
					dimensionIdx++;
				}

				// IMPORTANT NOTE: Known issue with mixed scope API calls
				// 	If calling none company scope API's, followed by company scope API's call this API first
				List<String> companies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);

				// Bypass during test mode (not enough test data setup to create invoice)
				List<c2g.CODAAPICommon.Reference> dimension1Refs = new List<c2g.CODAAPICommon.Reference>();
				List<c2g.CODAAPICommon.Reference> dimension2Refs = new List<c2g.CODAAPICommon.Reference>();
				List<c2g.CODAAPICommon.Reference> dimension3Refs = new List<c2g.CODAAPICommon.Reference>();
				List<c2g.CODAAPICommon.Reference> dimension4Refs = new List<c2g.CODAAPICommon.Reference>();
				if(!CODABasecamp.isTestMode())
				{
					// Upsert require dimensions on bulk
					dimension1Refs = c2g.CODAAPIDimension_3_0.UpsertDimensions1(null, dimension1);
					dimension2Refs = c2g.CODAAPIDimension_3_0.UpsertDimensions2(null, dimension2);
					dimension3Refs = c2g.CODAAPIDimension_3_0.UpsertDimensions3(null, dimension3);
					dimension4Refs = c2g.CODAAPIDimension_3_0.UpsertDimensions4(null, dimension4);
				}

				// Map ID's
				List<Map<String, ID>> dimensionsIds = new List<Map<String, ID>>();
				dimensionsIds.add(new Map<String, ID>());
				dimensionsIds.add(new Map<String, ID>());
				dimensionsIds.add(new Map<String, ID>());
				dimensionsIds.add(new Map<String, ID>());
				for(c2g.CODAAPICommon.Reference dimension : dimension1Refs)
					dimensionsIds[0].put(dimension.Name, dimension.Id);
				for(c2g.CODAAPICommon.Reference dimension : dimension2Refs)
					dimensionsIds[1].put(dimension.Name, dimension.Id);
				for(c2g.CODAAPICommon.Reference dimension : dimension3Refs)
					dimensionsIds[2].put(dimension.Name, dimension.Id);
				for(c2g.CODAAPICommon.Reference dimension : dimension4Refs)
					dimensionsIds[3].put(dimension.Name, dimension.Id);

				// Create the Invoice
				c2g.CODAAPIInvoiceTypes_3_0.Invoice invoice = new c2g.CODAAPIInvoiceTypes_3_0.Invoice();
				invoice.Account = new c2g.CODAAPICommon.Reference();
				invoice.Account.Id = Lookup.Account__c;
				invoice.InvoiceCurrency = new c2g.CODAAPICommon.Reference();
				invoice.InvoiceCurrency.Id = Lookup.Currency__c;
				invoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_3_0.InvoiceLineItems();
				invoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_3_0.InvoiceLineItem>();
				invoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_3_0.enumInvoiceStatus.InProgress;
				invoice.DueDate = System.now().addMonths(6).date();
				invoice.InvoiceDate = System.now().date();
				invoice.Period = new c2g.CODAAPICommon.Reference();
				invoice.Period.Id = Lookup.Period__c;
				invoice.PrintedText1AllowEdit = false;
				invoice.PrintedText2AllowEdit = false;
				invoice.PrintedText3AllowEdit = false;
				invoice.PrintedText4AllowEdit = false;
				invoice.PrintedText5AllowEdit = false;
				for(ReviewInvoiceLineItem reviewInvoiceLineItem : ReviewInvoiceLineItems)
				{
					// Create Invoice Line Item
					c2g.CODAAPIInvoiceLineItemTypes_3_0.InvoiceLineItem invoiceLineItem = new c2g.CODAAPIInvoiceLineItemTypes_3_0.InvoiceLineItem();
					// Resolve ID's for Dimensions
					String projectName = SelectedProject.Name;
					String todoListName = reviewInvoiceLineItem.TodoList.Name;
					String personName = reviewInvoiceLineItem.Person.FirstName + ' ' + reviewInvoiceLineItem.Person.LastName;
					ID[] dimensionIds = new ID[4];
					dimensionIds[projectDimensionIdx] = dimensionsIds[projectDimensionIdx].get(projectName);
					dimensionIds[todoDimensionIdx] = dimensionsIds[todoDimensionIdx].get(todoListName);
					dimensionIds[personDimensionIdx] = dimensionsIds[personDimensionIdx].get(personName);
					// Setup Invoice Line Item
					invoiceLineItem.Product = new c2g.CODAAPICommon.Reference();
					invoiceLineItem.Product.Id = Lookup.Product__c;
					if(dimensionIds[0]!=null)
					{
						invoiceLineItem.Dimension1 = new c2g.CODAAPICommon.Reference();
						invoiceLineItem.Dimension1.Id = dimensionIds[0];
					}
					if(dimensionIds[1]!=null)
					{
						invoiceLineItem.Dimension2 = new c2g.CODAAPICommon.Reference();
						invoiceLineItem.Dimension2.Id = dimensionIds[1];
					}
					if(dimensionIds[2]!=null)
					{
						invoiceLineItem.Dimension3 = new c2g.CODAAPICommon.Reference();
						invoiceLineItem.Dimension3.Id = dimensionIds[2];
					}
					if(dimensionIds[3]!=null)
					{
						invoiceLineItem.Dimension4 = new c2g.CODAAPICommon.Reference();
						invoiceLineItem.Dimension4.Id = dimensionIds[3];
					}
					invoiceLineItem.UnitPrice = unitPrice;
					invoiceLineItem.Quantity = Double.valueOf(reviewInvoiceLineItem.TimeEntry.Hours);
					invoiceLineItem.LineDescription = reviewInvoiceLineItem.TimeEntry.Description;
					invoiceLineItem.Scheduled = false;
					// Add line
					invoice.LineItems.LineItemList.add(invoiceLineItem);
				}

				// Bypass during test mode (not enough test data setup to create invoice)
				if(!CODABasecamp.isTestMode())
				{
					c2g.CODAAPICommon.Reference invoiceRef = c2g.CODAAPISalesInvoice_3_0.createInvoice(null, invoice);
					// Redirect to Edit Invoice page
					String url = Page.c2g__codaInvoiceEdit.getUrl() + '?id=' + invoiceRef.Id;
					PageReference pageRef = new PageReference(url);
					pageRef.setRedirect(true);
					return pageRef;
				}

				return null;
			}
			Step++;

			// Setup the available dimensions to map
			setupDimensionList();
		//}
		//catch (Exception e)
		//{
			//ApexPages.addMessages(e);
		//}
		return null;
	}

	public PageReference Back()
	{
		Step--;

		// Setup the available dimensions to map
		setupDimensionList();

		return null;
	}

	public List<SelectOption> getProjectList()
	{
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	for(CODABasecamp.ProjectEntry project : Projects)
   	 		options.add(new SelectOption(project.ID, project.Name));
   	 	return options;
	}

	private void setupDimensionList()
	{
		Map<String, String> mappedDimensions = new Map<String, String>();
		if(Step >= 2)
			mappedDimensions.put(SelectedDimensionProject, SelectedDimensionProject);
		if(Step >= 3)
			mappedDimensions.put(SelectedDimensionTodoList, SelectedDimensionTodoList);
		if(Step >= 4)
			mappedDimensions.put(SelectedDimensionPerson, SelectedDimensionPerson);
 	 	DimensionList = new List<SelectOption>();
		if(!mappedDimensions.ContainsKey('1'))
	 		DimensionList.add(new SelectOption('1', 'Dimension 1'));
		if(!mappedDimensions.ContainsKey('2'))
			DimensionList.add(new SelectOption('2', 'Dimension 2'));
		if(!mappedDimensions.ContainsKey('3'))
			DimensionList.add(new SelectOption('3', 'Dimension 3'));
		if(!mappedDimensions.ContainsKey('4'))
			DimensionList.add(new SelectOption('4', 'Dimension 4'));
	}

	public class SelectTodoList
	{
		public Boolean Selected { get; set; }
		public CODABasecamp.TodoList TodoList { get; set; }

		public SelectTodoList(CODABasecamp.TodoList todoList)
		{
			this.Selected = true;
			this.TodoList = todoList;
		}
	}

	public class SelectTimeEntry
	{
		public Boolean Selected { get; set; }
		public CODABasecamp.Person Person { get; set; }
		public CODABasecamp.TimeEntry TimeEntry { get; set; }
		public CODABasecamp.TodoList TodoList { get; set; }

		public SelectTimeEntry(CODABasecamp.Person person, CODABasecamp.TimeEntry timeEntry, CODABasecamp.TodoList todoList)
		{
			this.Selected = true;
			this.Person = person;
			this.TimeEntry = timeEntry;
			this.TodoList = todoList;
		}
	}

	public class ReviewInvoiceLineItem
	{
		public CODABasecamp.Person Person { get; set; }
		public CODABasecamp.TimeEntry TimeEntry { get; set; }
		public CODABasecamp.TodoList TodoList { get; set; }

		public ReviewInvoiceLineItem(CODABasecamp.Person person, CODABasecamp.TimeEntry timeEntry, CODABasecamp.TodoList todoList)
		{
			this.Person = person;
			this.TimeEntry = timeEntry;
			this.TodoList = todoList;
		}
	}

	public class WizardException extends Exception
	{
	}

	public class DimensionInfo
	{
		public String Name;
		public String Id;
	}

	public class StopException extends Exception
	{

	}

}