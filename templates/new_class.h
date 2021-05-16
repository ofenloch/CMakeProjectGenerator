#ifndef _NEW_CLASS_H_
#define _NEW_CLASS_H_

/**
 * @brief CNewClass doing some stuff ...
 *
 */
class CNewClass {
public:
  /**
   * @brief Construct a new CNewClass object
   *
   */
  CNewClass();
  /**
   * @brief Destroy the CNewClass object
   *
   */
  virtual ~CNewClass();

private:
  /**
   * @brief Initialize the CNewClass object
   * @return 0 on successfull initialization or error code if something went
   * wrong
   *
   */
  int initialize();
}; // CNewClass

#endif // #ifndef _NEW_CLASS_H_