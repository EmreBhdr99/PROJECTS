import streamlit as st
import pickle
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from PIL import Image
from sklearn.preprocessing import LabelEncoder
import base64

st.set_page_config(layout='wide')

st.sidebar.title('Employee Information')
html_temp = """
<div style="background-color:Black;padding:10px">
<h2 style="color:cyan;text-align:center;font-size: 50px;">Employee Churn Prediction</h2>
</div><br>"""

st.markdown(html_temp, unsafe_allow_html=True)
original_title = '<p style="font-family:Courier; color:Blue; text-align:center; font-size: 50px;"><b>Select Your Model</b></p>'
st.markdown(original_title, unsafe_allow_html=True)
selection = st.selectbox("", ["XGBoost", "Random Forest", "KNN", "ANN"])


if selection =="XGBoost":
	st.write("You selected", selection, "model")
	model = pickle.load(open("xgboost_model",'rb'))
elif selection =="Random Forest":
	st.write("You selected", selection, "model")
	model = pickle.load(open('random_forest_model','rb'))
elif selection =="ANN":
	st.write("You selected", selection, "model")
	model = pickle.load(open('ann_model','rb'))
else:
	st.write("You selected", selection, "model")
	model = pickle.load(open('kneighbors_model','rb'))

satisfaction_level = st.sidebar.slider(label="Satisfaction Level", min_value=0.0, max_value=1.0, step=0.01)
last_evaluation = st.sidebar.slider(label="Last Evaluation", min_value=0.0, max_value=1.0, step=0.01)
number_project = st.sidebar.slider(label="number_project", min_value=2, max_value=7, step=1)
average_monthly_hours = st.sidebar.slider(label="average_monthly_hours", min_value=90, max_value=310, step=10)
time_spend_company = st.sidebar.slider("Time Spend in Company", min_value=1, max_value=10, step=1)
work_accident = st.sidebar.radio("Work Accident", (1, 0))
promotion_last_5years = st.sidebar.radio("Promotion in Last 5 Years", (1, 0))
departments = st.sidebar.selectbox("Department", ['RandD', 'Accounting', 'HR', 'Management', 'Marketing', 'ProductManager',  'Sales', 'Support', 'Technical', 'IT'])
salary = st.sidebar.selectbox("Salary", ['low', 'medium', 'high'])


my_dict = {'satisfaction_level':satisfaction_level, 'last_evaluation':last_evaluation, 'number_project':number_project, 'average_montly_hours':average_monthly_hours,\
			'time_spend_company':time_spend_company, 'work_accident':work_accident, 'promotion_last_5years':promotion_last_5years,\
			'departments': departments, 'salary':salary}
columns = ['satisfaction_level', 'last_evaluation', 'number_project',
       'average_montly_hours', 'time_spend_company', 'work_accident',
       'promotion_last_5years', 'departments', 'salary']

df = pd.DataFrame.from_dict([my_dict])
encoder = LabelEncoder()
df[["departments","salary"]] = df[["departments","salary"]].apply(encoder.fit_transform)
user_inputs = df


scalerfile = 'scaler.sav'
scaler = pickle.load(open(scalerfile, 'rb'))
scaler.clip = False
user_inputs_transformed = scaler.transform(user_inputs)

prediction = model.predict(user_inputs_transformed)


st.markdown("<h1 style='text-align: center; color: red;'>Employee Information</h1>", unsafe_allow_html=True)
st.table(df)
st.markdown("<h1 style='text-align: center; color: green; font-size: 35px;'><b>Click PREDICT button if configuration is OK</b></h1>", unsafe_allow_html=True)
# st.subheader('Click PREDICT if configuration is OK')

m = st.markdown("""
<style>
div.stButton > button:first-child {
    background-color: #0099ff;
    color:#ffffff;
}
div.stButton > button:hover {
    background-color: #00ff00;
    color:#ff0000;
    }
</style>""", unsafe_allow_html=True)



if st.button('PREDICT'):
	if prediction[0]==0:
		st.success(prediction[0])
		st.success(f'Employee will STAY :)')
	elif prediction[0]==1:
		st.warning(prediction[0])
		st.warning(f'Employee will LEAVE :(')



# # you can create columns to better manage the flow of your page
# # this command makes 3 columns of equal width
# col1, col2 = st.columns(2)

# # this will put a button in the middle column
# with col2:
# 	if st.button("PREDICT"):
# 		if prediction[0]==0:
# 			st.success(prediction[0])
# 			st.success(f'Employee will STAY :)')
# 		elif prediction[0]==1:
# 			st.warning(prediction[0])
# 			st.warning(f'Employee will LEAVE :(')