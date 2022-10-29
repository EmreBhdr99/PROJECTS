import streamlit as st
import pickle
import pandas as pd


st.sidebar.title('Car Price Prediction')
html_temp = """
<div style="background-color:red;padding:10px">
<h2 style="color:white;text-align:center;">F3590-Emre Auto Scout Project </h2>
</div>"""
st.markdown(html_temp,unsafe_allow_html=True)


age=st.sidebar.selectbox("What is the age of your car:",(0,1,2,3,4,5))
hp=st.sidebar.slider("What is the hp of your car?", 60, 300, step=5)
km=st.sidebar.slider("What is the km of your car", 0,200000, step=500)
gearing_type=st.sidebar.radio('Select gear type',('Automatic','Manual','Semi-automatic'))
car_model=st.sidebar.selectbox("Select model of your car", ('A1', 'A2', 'A3','Astra','Clio','Corsa','Espace','Insignia'))


model_name=st.selectbox("Select your model:",("XGBOOST","Random Forest"))

if model_name=="XGBOOST":
	model=pickle.load(open("xgb_model","rb"))
	st.success("You selected {} model".format(model_name))
else :
	model=pickle.load(open("rf_model","rb"))
	st.success("You selected {} model".format(model_name))



my_dict = {
    "age": age,
    "hp": hp,
    "km": km,
    "model": car_model,
    'gearing_type':gearing_type
}

df = pd.DataFrame.from_dict([my_dict])


st.header("The configuration of your car is below")
st.table(df)

columns= ['age','hp', 'km', 'model_A1', 'model_A2', 'model_A3', 'model_Astra', 'model_Clio', 'model_Corsa', 'model_Espace',
'model_Insignia',
'gearing_type_Automatic',
'gearing_type_Manual',
'gearing_type_Semi-automatic']


df = pd.get_dummies(df).reindex(columns=columns, fill_value=0)

st.subheader("Press predict if configuration is okay")

if st.button("Predict"):
    prediction = model.predict(df)
    st.success("The estimated price of your car is €{}. ".format(int(prediction[0])))
    
