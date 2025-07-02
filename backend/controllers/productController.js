import { sql, pool, poolConnect } from '../db.js';

//  GET all products
export const getProducts = async (req, res) => {
  try {
    await poolConnect;
    const keyword = req.query.search || '';

    const result = await pool.request()
      .input('search', sql.NVarChar, `%${keyword}%`)
      .query(
        keyword
          ? "SELECT * FROM PRODUCTS WHERE PRODUCTNAME LIKE @search"
          : "SELECT * FROM PRODUCTS"
      );

    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};
;

//  GET product by ID
export const getProduct = async (req, res) => {
  const id = req.params.id;
  try {
    await poolConnect;
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query('SELECT * FROM PRODUCTS WHERE PRODUCTID = @id');

    if (result.recordset.length === 0)
      return res.status(404).json({ message: 'Not found' });

    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Error fetching product:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

//  POST create product
export const createProduct = async (req, res) => {
  const { PRODUCTNAME, PRICE, STOCK } = req.body;

  if (!PRODUCTNAME || PRICE <= 0 || STOCK < 0)
    return res.status(400).json({ message: 'Invalid input' });

  try {
    await poolConnect;

    // Insert and get the new product ID
    const insertResult = await pool.request()
      .input('name', sql.NVarChar, PRODUCTNAME)
      .input('price', sql.Decimal(10, 2), PRICE)
      .input('stock', sql.Int, STOCK)
      .query(
        `INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK)
         OUTPUT INSERTED.*
         VALUES (@name, @price, @stock)`
      );

    const newProduct = insertResult.recordset[0];

    res.status(201).json(newProduct); 
  } catch (err) {
    console.error('Error creating product:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};


//  PUT update product
export const updateProduct = async (req, res) => {
  const id = req.params.id;
  const { PRODUCTNAME, PRICE, STOCK } = req.body;

  if (!PRODUCTNAME && PRICE == null && STOCK == null)
    return res.status(400).json({ message: 'No fields to update' });

  await poolConnect;

  const request = pool.request().input('id', sql.Int, id);

  let updateFields = [];

  if (PRODUCTNAME) {
    request.input('name', sql.NVarChar, PRODUCTNAME);
    updateFields.push('PRODUCTNAME = @name');
  }

  if (PRICE != null) {
    request.input('price', sql.Decimal(10, 2), PRICE);
    updateFields.push('PRICE = @price');
  }

  if (STOCK != null) {
    request.input('stock', sql.Int, STOCK);
    updateFields.push('STOCK = @stock');
  }

  const query = `
    UPDATE PRODUCTS
    SET ${updateFields.join(', ')}
    OUTPUT INSERTED.*
    WHERE PRODUCTID = @id
  `;

  const result = await request.query(query);
  const updatedProduct = result.recordset[0];

  res.json(updatedProduct); 
};



//  DELETE product
export const deleteProduct = async (req, res) => {
  const id = req.params.id;

  try {
    await poolConnect;
    await pool.request()
      .input('id', sql.Int, id)
      .query('DELETE FROM PRODUCTS WHERE PRODUCTID=@id');

    res.json({ message: 'Product deleted' });
  } catch (err) {
    console.error('Error deleting product:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};
