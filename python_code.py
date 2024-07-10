
#!/usr/bin/env python
# coding: utf-8

# ### Installing and importing kaggle

# In[1]:


#!pip install kaggle
import kaggle


# ### downloading dataset from kaggle using API

# In[2]:


get_ipython().system('kaggle datasets download ankitbansal06/retail-orders -f orders.csv')


# ### unzipping the downloaded file using zipfile library

# In[3]:


import zipfile
zip_ref = zipfile.ZipFile('orders.csv.zip')
zip_ref.extractall()
zip_ref.close()


# ### Reading data from file using pandas

# In[4]:


import pandas as pd
orders = pd.read_csv('orders.csv',na_values=['Not Available','unknown'])


# ### Renaming columns names

# In[5]:


orders.columns = orders.columns.str.lower()


# In[8]:


orders.columns = orders.columns.str.replace(' ','_')


# ### Displaying the top 10 rows of the data

# In[9]:


orders.head(10)


# ### Deriving new columns discount, sale_price and profit

# In[10]:


orders['discount'] = orders['list_price']*orders['discount_percent']*0.01
orders['sale_price'] = orders['list_price']-orders['discount']
orders['profit'] = orders['sale_price']-orders['cost_price']
orders


# ### converting order date from object data type to datetime

# In[11]:


pd.to_datetime(orders['order_date'],format = "%Y-%m-%d")


# ### dropping the unrequired columns

# In[12]:


orders.drop(columns = ['list_price','cost_price','discount_percent'],inplace = True)


# ### Installing and importing psycopg2 library to connect with SQL server

# In[13]:


#!pip install psycopg2
import psycopg2


# ### Importing the required libraries and connecting to database

# In[14]:


import pandas as pd
from sqlalchemy import create_engine

host = "<host_name>"
database = "<database_name>"
username = "<username>"
password = "<password>"

# Assuming you have a DataFrame named df containing your data
# Replace 'postgresql://username:password@localhost/database_name' with your PostgreSQL connection string
connection_string = f'postgresql://{username}:{password}@{host}:5432/{database}'
engine = create_engine(connection_string)

# Assuming you have a DataFrame named orders containing your data
# Replace 'orders' with the name of your DataFrame containing the data
#orders = pd.DataFrame(...)  # Replace ... with your actual data

# Load the DataFrame into the PostgreSQL database
orders.to_sql('orders', engine, if_exists='append', index=False)

# Close the database connection
engine.dispose()
