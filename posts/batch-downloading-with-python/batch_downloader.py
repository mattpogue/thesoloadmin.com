#!/usr/bin/python3

from bs4 import BeautifulSoup
import urllib3.request
import re

# The site's base URL
base_url = 'https://www.whateverwhatever.com'

# Session Cookie, retrieved from the browser after authenticating successfully. We'll need to submit this with each request.
session_cookie = '_SessionId=cmKMxrYDzpULXcMbwtuYDNjzdRCWdGS9xgOPUQtbyAdjyu4LvlPylF3ICxVj3V7NSs%2BliTKtRCRNbEc8BhzCdMGeHWJyyT8n0NEaJ7DKU20TzsuD9FZtMbH5od4xhKrE96vlqDvuPEYegbPtL14Of%2BZZsCI4jXCRRcSk%2FojgBYg%2Bwf%2FICDk3MM5STbkkLvWFXR8PK0Xvg6DBy0mnzR2t2jBh7mPijOLFiFRiVriwze8Xkci2QDmziMrclTxHCMWCqjERGFs4wxwJ9f%2BiWq1Y7CEZx5W5GmEyrwRRUJwVGu2dk%2Bfr82Jr3L09GKB1--y9bG00G4CVBMovga--3DplyhIxzHXKYRswjnQfBw%3D%3D'

# New instance of the PoolManager()
http = urllib3.PoolManager()

# Create the request
req = http.request('GET', base_url + '/my-company/purchase_orders?page=1', headers={'Cookie':session_cookie})

# Create the HTML parser
soup = BeautifulSoup(req.data, 'html.parser')

# Loop through all page links, using "re" to find the links we need
for link in soup.find_all('a', string=True):
    if re.search('\/purchase_orders\/\d*\/edit$', link.get('href')):

        # Split each link into an array, excluding the final element
        link_parts = link.get('href').split('/')[:-1]
        
        # Rejoin into the required link format and assign the full URL 
        details_link_after_base = '/'.join(link_parts)
        details_page_link = base_url + details_link_after_base
        
        # Get the Details page and assign to a BeautifulSoup variable
        details_page = http.request('GET', details_page_link, headers={'Cookie':session_cookie})
        po_details_html = BeautifulSoup(details_page.data, 'html.parser')
        
        # Look for the CSS class "my-4" - this is the parent element for our download link
        po_number_div = po_details_html.find('div', class_='my-4')

        # Assign a filename variable using the purchase order number, located in the div's contents
        filename = 'purchase_order_' + po_number_div.contents[0].contents[0] + '.pdf'

        # Locate the download link
        file_url_part = po_details_html.find('a', class_='btn-primary').get('href')
        full_download_link = base_url + file_url_part
        
        # Print a status message, download the PDF, and save to disk
        print("Downloading PO from link " + full_download_link)
        file_req = http.request('get', full_download_link)
        with open(filename, 'wb') as f:
            f.write(file_req.data)