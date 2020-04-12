
This is a sample code I wrote to handle calling store procedures on a database that return data to be displayed on a table.  The purpose is to show some programming techniques and best practices.

Given that this piece of code was used by multiple projects handling store procedure calls, a parent class was created. The FunctionRecord:Base class allowed to share some common logic (https://github.com/ignacio753/code-sample-a/blob/master/gems/function_record.rb).  This base class is charge of creating the SQL statements to make the database call.  It expects from its children classes: a function_name attribute (as the name says is the name of the db procedure/function to call), required_query_params (name of params that are required, if a param is empty of null it will raise an exception) and args_from_params (these takes the params coming from the API endpoint and formats them with proper defaults)

For this particular application, the app had several API endpoints dealing with table data calls.  These all had very similar parameters and validations, for this reason a class called TableDataBase was created (https://github.com/ignacio753/code-sample-a/blob/master/models/table_data_base.rb). This class overrides the args_from_params and required_query_params methods from the FunctionRecord class.  The args_from_params method uses other methods to fill the array of parameters. These methods have been grouped in logical groups, for example one that handles pagination and other that handles sorting.  This allows the children classes and its store procedures to call and re-use these methods.

The process is more easily seen on the TableDataSPP child class (https://github.com/ignacio753/code-sample-a/blob/master/models/table_data_spp.rb).  The class inherits from TableDataBase and overrides the args_from_params to call only those methods that it really needs, plus adding any other that are specific to its own class.

I strive for clean, efficient and testable code, as well as following the DRY and single responsibility principles. By writing small functions, not only is each method encapsulated and does only one thing, but also implementing unit testing is greatly simplified.
