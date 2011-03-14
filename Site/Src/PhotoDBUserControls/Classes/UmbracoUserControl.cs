﻿using System;
using umbraco.interfaces;
using umbraco.NodeFactory;

namespace PhotoDBUserControls.Classes
{
    public class UmbracoUserControl : System.Web.UI.UserControl
    {
        private Node _node = null;

        protected string GetProperty(string propertyName)
        {
            if (_node == null)
                _node = Node.GetCurrent();

            IProperty prop = _node.GetProperty(propertyName);
            if (prop == null)
                return String.Format("Property {0} not found in node {1}!", propertyName, _node.Id);

            return prop.Value;
        }

    }
}