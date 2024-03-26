import os
import boto3
import sys
import time


def get_ordered_files(directory):
    """This function returns a list of files in a given directory. For files in the repeatable folder, the files will be returned in this order. 
    1- udf
    2- table
    3- view
    4- stored-procedure
    """
    repeatable_udf_paths = []
    repeatable_table_paths = []
    repeatable_view_paths = []
    repeatable_sp_paths = []
    file_paths = []

    if "/repeatable" in directory:
        for root, directories, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                if file_path.endswith(".sql"):
                    if "/udf" in file_path:
                        repeatable_udf_paths.append(file_path)
                    elif "/table" in file_path:
                        repeatable_table_paths.append(file_path)
                    elif "/view" in file_path:
                        repeatable_view_paths.append(file_path)
                    elif "/stored-procedure" in file_path:
                        repeatable_sp_paths.append(file_path)
                    else:
                        pass
                file_paths = repeatable_udf_paths + repeatable_table_paths + \
                    repeatable_view_paths + repeatable_sp_paths
    else:
        for root, directories, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                if file_path.endswith(".sql"):
                    file_paths.append(file_path)

    return file_paths


def get_contents_from_file(filename):
    """Read a file and return the contents as a string"""
    contents = ''
    with open(filename, 'r', errors='ignore', encoding='utf-8') as file:
        contents = file.read()
    return contents


def execute_sql_statement(filename, cluster_id, db_name, secret_arn, aws_region):
    """Execute SQL statements in a file"""
    redshift_client = boto3.client(
        'redshift-data', region_name=aws_region)
    contents = get_contents_from_file(filename),
    response = redshift_client.execute_statement(
        Sql=contents[0],
        ClusterIdentifier=cluster_id,
        Database=db_name,
        WithEvent=True,
        StatementName=filename,
        SecretArn=secret_arn
    )
    # Get the query ID to fetch the results
    query_id = response['Id']
    response = redshift_client.describe_statement(
        Id=query_id
    )
    status = response['Status']
    while status == 'SUBMITTED' or status == 'STARTED' or status == 'PICKED':
        # Wait for some time before checking the status again
        time.sleep(1)
        response = redshift_client.describe_statement(
            Id=query_id
        )
        status = response['Status']
        print('Status:', status)
        if status == 'FAILED':
            print('SQL execution failed.')
            print('Error message:', response['Error'])
        elif status == 'FINISHED':
            print('SQL execution successful.')
        # Wait for some time before checking the status again
        if status != 'FINISHED':
            time.sleep(1)


def main(sql_src_folder, redshift_cluster_name, redshift_database_name, redshift_secret_arn, aws_region):
    # Get the sql file paths
    file_paths = get_ordered_files(sql_src_folder)

    # Execute the sql queries
    executed_queries = set()
    for path in file_paths:
        if path in executed_queries:
            print(f"Skipping execution of {path}. Already executed.")
            continue

        print("-------------------------------------------------------------------")
        print(path)
        print("-------------------------------------------------------------------")
        execute_sql_statement(path, redshift_cluster_name,
                              redshift_database_name, redshift_secret_arn, aws_region)
        executed_queries.add(path)


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
